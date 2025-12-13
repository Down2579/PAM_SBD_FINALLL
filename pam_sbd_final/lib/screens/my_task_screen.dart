import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers.dart';
import 'detail_screen.dart';
import 'add_item_screen.dart'; // ✅ Pastikan import ini ada

class MyTaskScreen extends StatefulWidget {
  const MyTaskScreen({super.key});

  @override
  State<MyTaskScreen> createState() => _MyTaskScreenState();
}

class _MyTaskScreenState extends State<MyTaskScreen> {
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
    final currentUser = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: bgPage,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Tasks",
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      
      // ✅ TOMBOL TAMBAH (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke Halaman Tambah Barang
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const AddItemScreen())
          );
        },
        backgroundColor: darkNavy,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),

      body: Column(
        children: [
          // 1. HEADER & FILTER SECTION
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Reported Items",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkNavy),
                ),
                Text(
                  "Track status of items you have reported.",
                  style: TextStyle(fontSize: 13, color: textGrey),
                ),
                
                const SizedBox(height: 20),

                // Date Filter Row
                Row(
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
                List<Barang> myItems = provider.listBarang.where((item) {
                  bool isOwner = item.pelapor?.id == currentUser?.id;
                  
                  bool dateMatch = true;
                  if (_selectedDate != null && item.createdAt != null) {
                    dateMatch = DateUtils.isSameDay(item.createdAt, _selectedDate!);
                  }

                  return isOwner && dateMatch;
                }).toList();

                // Sort by Latest
                myItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (myItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("You haven't reported any items yet.", style: TextStyle(color: textGrey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 80), // Padding bawah agar tidak tertutup FAB
                  itemCount: myItems.length,
                  itemBuilder: (context, index) {
                    return _buildTaskCard(myItems[index]);
                  },
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
    bool isLost = item.tipeLaporan == 'hilang';
    String statusText = isLost ? "Lost!!" : "Found!!";

    String processStatus = item.status.toUpperCase().replaceAll('_', ' ');
    Color processColor = Colors.grey;
    if (item.status == 'open') processColor = Colors.blue;
    if (item.status == 'proses_klaim') processColor = warningOrange;
    if (item.status == 'selesai') processColor = successGreen;

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

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: processColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: processColor.withOpacity(0.3))
                        ),
                        child: Text(
                          processStatus, 
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: processColor)
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.namaBarang,
                    style: TextStyle(fontSize: 14, color: textDark, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: textGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.lokasi?.namaLokasi ?? "Unknown Location",
                          style: TextStyle(fontSize: 12, color: textGrey),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}