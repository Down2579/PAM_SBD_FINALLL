import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers.dart';
import 'detail_screen.dart';

class CompletedScreen extends StatefulWidget {
  const CompletedScreen({super.key});

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  DateTime? _selectedDate;

  // ================= COLORS PALETTE =================
  final Color bgPage = const Color(0xFFF1F3F7);
  final Color darkNavy = const Color(0xFF2B4263);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGrey = const Color(0xFF9CA3AF);
  final Color successGreen = const Color(0xFF10B981);
  final Color errorRed = const Color(0xFFEF4444);

  final String baseUrlImage = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<BarangProvider>(context, listen: false)
            .fetchBarang(refresh: true));
  }

  // ================= DATE PICKER =================
  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime oneYearAgo = now.subtract(const Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: oneYearAgo,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: darkNavy,
              onPrimary: Colors.white,
              onSurface: textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: bgPage,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Icon(Icons.check_circle_rounded,
                    color: successGreen, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Completed",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textDark)),
                  Text("All resolved items",
                      style: TextStyle(
                          fontSize: 12,
                          color: textGrey,
                          fontWeight: FontWeight.w500)),
                ],
              )
            ],
          ),
        ),
      ),

      // ================= BODY =================
      body: Column(
        children: [
          // ================= FILTER =================
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Filter by Date:",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                InkWell(
                  onTap: () => _pickDate(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.black.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 16, color: darkNavy),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDate == null
                              ? 'All Dates'
                              : DateFormat('dd MMM yyyy')
                                  .format(_selectedDate!),
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textDark),
                        ),
                        if (_selectedDate != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _selectedDate = null),
                            child: Icon(Icons.close_rounded,
                                size: 16, color: errorRed),
                          )
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= LIST =================
          Expanded(
            child: Consumer<BarangProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return Center(
                      child:
                          CircularProgressIndicator(color: darkNavy));
                }

                final completedItems = provider.listBarang.where((item) {
                  final bool isCompleted = item.status == 'selesai';
                  bool dateMatch = true;

                  if (_selectedDate != null && item.createdAt != null) {
                    dateMatch = DateUtils.isSameDay(
                        item.createdAt, _selectedDate!);
                  }
                  return isCompleted && dateMatch;
                }).toList()
                  ..sort((a, b) =>
                      b.createdAt.compareTo(a.createdAt));

                if (completedItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.playlist_add_check_rounded,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text("Belum ada barang selesai.",
                            style: TextStyle(
                                color: textGrey, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  itemCount: completedItems.length,
                  itemBuilder: (context, index) =>
                      _buildCompletedCard(completedItems[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMPLETED CARD =================
  Widget _buildCompletedCard(Barang item) {
    final bool isLost = item.tipeLaporan == 'hilang';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.6),
              blurRadius: 1,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            // ================= IMAGE =================
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: darkNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.white.withOpacity(0.8), width: 1.5),
                image: (item.gambarUrl != null &&
                        item.gambarUrl!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(
                          item.gambarUrl!.startsWith('http')
                              ? item.gambarUrl!
                              : '$baseUrlImage${item.gambarUrl}',
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (item.gambarUrl == null ||
                      item.gambarUrl!.isEmpty)
                  ? const Center(
                      child: Icon(Icons.inventory_2_outlined,
                          color: Colors.white, size: 35))
                  : null,
            ),

            const SizedBox(width: 16),

            // ================= TEXT =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _statusBadge(isLost),
                      const Spacer(),
                      if (item.kategori?.namaKategori != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.kategori!.namaKategori,
                            style: TextStyle(
                                fontSize: 10, color: textDark),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item.namaBarang,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: textDark)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: textGrey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.lokasi?.namaLokasi ?? "-",
                          style: TextStyle(
                              fontSize: 13, color: textGrey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ================= CHECK =================
            const SizedBox(width: 8),
            Icon(Icons.check_box_rounded,
                color: successGreen, size: 32),
          ],
        ),
      ),
    );
  }

  // ================= STATUS BADGE =================
  Widget _statusBadge(bool isLost) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isLost
            ? Colors.red.withOpacity(0.12)
            : Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isLost ? "LOST" : "FOUND",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: isLost ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
