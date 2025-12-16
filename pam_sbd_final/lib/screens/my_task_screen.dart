import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers.dart';
import 'detail_screen.dart';
import 'add_item_screen.dart';
import 'user_claim_validation_page.dart';

class MyTaskScreen extends StatefulWidget {
  const MyTaskScreen({super.key});

  @override
  State<MyTaskScreen> createState() => _MyTaskScreenState();
}

class _MyTaskScreenState extends State<MyTaskScreen> {
  DateTime? _selectedDate;

  // ================= COLORS (CONSISTENT) =================
  final Color bgPage = const Color(0xFFF1F3F7);
  final Color darkNavy = const Color(0xFF0F3460);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGrey = const Color(0xFF9CA3AF);

  final Color successGreen = const Color(0xFF10B981);
  final Color warningOrange = const Color(0xFFF59E0B);
  final Color errorRed = const Color(0xFFEF4444);
  final Color pendingPurple = const Color(0xFF8B5CF6);

  final String baseUrlImage = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BarangProvider>(context, listen: false)
          .fetchBarang(refresh: true);
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final threeMonthsAgo = now.subtract(const Duration(days: 90));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: threeMonthsAgo,
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

    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: bgPage,
        elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: textDark,
          size: 22,
        ),
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
        title: Text("My Tasks",
            style:
                TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: darkNavy,
        elevation: 6,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemScreen()),
          );
          if (mounted) {
            Provider.of<BarangProvider>(context, listen: false)
                .fetchBarang(refresh: true);
          }
        },
        child: const Icon(Icons.add_rounded,
            color: Colors.white, size: 28),
      ),

      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your Reported Items",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkNavy)),
                Text("Lacak status barang yang Anda laporkan.",
                    style: TextStyle(fontSize: 13, color: textGrey)),
                const SizedBox(height: 20),

                // DATE FILTER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Filter by Date:",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    InkWell(
                      onTap: () => _pickDate(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: _cardDecoration(),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 16, color: darkNavy),
                            const SizedBox(width: 8),
                            Text(
                              _selectedDate == null
                                  ? 'Select Date'
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
              ],
            ),
          ),

          // ================= LIST =================
          Expanded(
            child: Consumer<BarangProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: darkNavy));
                }

                final myItems = provider.listBarang.where((item) {
                  final isOwner =
                      item.pelapor?.id == currentUser?.id;
                  bool dateMatch = true;
                  if (_selectedDate != null &&
                      item.createdAt != null) {
                    dateMatch = DateUtils.isSameDay(
                        item.createdAt, _selectedDate!);
                  }
                  return isOwner && dateMatch;
                }).toList()
                  ..sort((a, b) =>
                      b.createdAt.compareTo(a.createdAt));

                if (myItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined,
                            size: 60,
                            color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Belum ada laporan barang.",
                            style: TextStyle(color: textGrey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(24, 10, 24, 90),
                  itemCount: myItems.length,
                  itemBuilder: (_, i) =>
                      _buildTaskCard(myItems[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= TASK CARD =================
  Widget _buildTaskCard(Barang item) {
    final isLost = item.tipeLaporan == 'hilang';
    final statusText = isLost ? "LOST" : "FOUND";

    String processStatus;
    Color processColor;

    switch (item.status) {
      case 'pending':
        processStatus = "MENUNGGU VERIFIKASI";
        processColor = pendingPurple;
        break;
      case 'open':
        processStatus = "PUBLISHED";
        processColor = Colors.blue;
        break;
      case 'proses_klaim':
        processStatus = "PROSES KLAIM";
        processColor = warningOrange;
        break;
      case 'selesai':
        processStatus = "SELESAI";
        processColor = successGreen;
        break;
      default:
        processStatus = item.status.toUpperCase();
        processColor = Colors.grey;
    }

    final hasIncomingClaim =
        item.status == 'proses_klaim' &&
            item.statusVerifikasi == 'menunggu_pemilik';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DetailScreen(item: item)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Row(
              children: [
                // IMAGE
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white, width: 1.5),
                    image: item.gambarUrl != null &&
                            item.gambarUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(
                              item.gambarUrl!.startsWith('http')
                                  ? item.gambarUrl!
                                  : '$baseUrlImage${item.gambarUrl}',
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: darkNavy,
                  ),
                  child: item.gambarUrl == null ||
                          item.gambarUrl!.isEmpty
                      ? const Icon(Icons.inventory_2,
                          color: Colors.white, size: 32)
                      : null,
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          // LOST / FOUND BADGE
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4),
                            decoration: BoxDecoration(
                              color: (isLost
                                      ? warningOrange
                                      : successGreen)
                                  .withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isLost
                                      ? warningOrange
                                      : successGreen),
                            ),
                          ),

                          // PROCESS BADGE
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  processColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              processStatus,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: processColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(item.namaBarang,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: textDark)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: textGrey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.lokasi?.namaLokasi ??
                                  "Unknown Location",
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: textGrey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.grey[300]),
              ],
            ),

            if (hasIncomingClaim) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const UserClaimValidationPage()),
                    );
                    if (mounted) {
                      Provider.of<BarangProvider>(context,
                              listen: false)
                          .fetchBarang(refresh: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: warningOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.white,
                      size: 18),
                  label: const Text("Cek Klaim Masuk",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= CARD DECORATION =================
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border:
          Border.all(color: Colors.black.withOpacity(0.04)),
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
    );
  }
}
