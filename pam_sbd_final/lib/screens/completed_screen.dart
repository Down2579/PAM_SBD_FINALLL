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
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color darkNavy = const Color(0xFF2B4263);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGrey = const Color(0xFF9CA3AF);
  final Color successGreen = const Color(0xFF10B981);
  final Color warningOrange = const Color(0xFFF59E0B);
  final Color errorRed = const Color(0xFFEF4444);

  // Base URL Image
  final String baseUrlImage = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<BarangProvider>(context, listen: false).fetchBarang(refresh: true)
    );
  }

  // Logic Date Picker (Konsisten)
  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime threeMonthsAgo = now.subtract(const Duration(days: 90));

    final DateTime? picked = await showDatePicker(
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

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: bgPage,
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan back button default (karena di bottom nav)
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.check_circle_rounded, color: successGreen, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Completed", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark)),
                  Text("Items successfully returned", style: TextStyle(fontSize: 12, color: textGrey, fontWeight: FontWeight.w500)),
                ],
              )
            ],
          ),
        ),
      ),
      
      body: Column(
        children: [
          // 1. FILTER SECTION
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Filter by Date:", style: TextStyle(fontWeight: FontWeight.w600)),
                
                InkWell(
                  onTap: () => _pickDate(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)]
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16, color: darkNavy),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDate == null 
                              ? 'Select Date' 
                              : DateFormat('dd MMM yyyy').format(_selectedDate!),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textDark),
                        ),
                        if (_selectedDate != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _selectedDate = null),
                            child: Icon(Icons.close_rounded, size: 16, color: errorRed),
                          )
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. LIST ITEMS
          Expanded(
            child: Consumer<BarangProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator(color: darkNavy));
                }

                // --- FILTER LOGIC ---
                // Hanya tampilkan barang yang statusnya 'selesai'
                List<Barang> completedItems = provider.listBarang.where((item) {
                  // 1. Status Filter
                  bool isCompleted = item.status == 'selesai';

                  // 2. Date Filter
                  bool dateMatch = true;
                  if (_selectedDate != null && item.createdAt != null) {
                    dateMatch = DateUtils.isSameDay(item.createdAt, _selectedDate!);
                  }

                  return isCompleted && dateMatch;
                }).toList();

                // Sort by Latest
                completedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (completedItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.playlist_add_check_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text("No completed items yet.", style: TextStyle(color: textGrey, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  itemCount: completedItems.length,
                  itemBuilder: (context, index) {
                    return _buildCompletedCard(completedItems[index]);
                  },
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
    bool isLost = item.tipeLaporan == 'hilang';
    String statusText = isLost ? "Lost!!" : "Found!!";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => DetailScreen(item: item))
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ]
        ),
        child: Row(
          children: [
            // 1. FOTO BARANG (KIRI)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: darkNavy,
                borderRadius: BorderRadius.circular(16),
                image: (item.gambarUrl != null && item.gambarUrl!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(
                          item.gambarUrl!.startsWith('http') 
                            ? item.gambarUrl! 
                            : '$baseUrlImage${item.gambarUrl}'
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (item.gambarUrl == null || item.gambarUrl!.isEmpty)
                  ? const Center(child: Icon(Icons.inventory_2_outlined, color: Colors.white, size: 35))
                  : null,
            ),

            const SizedBox(width: 16),

            // 2. DETAIL TEXT (TENGAH)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Nama Barang
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 16, color: textGrey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.namaBarang,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textDark),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),

                  // Tanggal Selesai (Menggunakan updated_at sebagai tanggal penyelesaian)
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16, color: textGrey),
                      const SizedBox(width: 6),
                      Text(
                        // Asumsi: updated_at adalah tanggal status berubah jadi 'selesai'
                        // Jika Anda punya field 'completed_at', pakai itu.
                        DateFormat('dd MMM yyyy').format(item.createdAt), // Fallback ke created jika update null
                        style: TextStyle(fontSize: 13, color: textGrey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. CHECK ICON (KANAN)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.check_box_rounded, color: successGreen, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}