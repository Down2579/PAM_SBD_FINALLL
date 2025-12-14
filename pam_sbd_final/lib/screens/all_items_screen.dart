import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers.dart';
import 'detail_screen.dart';

class AllItemsScreen extends StatefulWidget {
    final String filterType;
  final String? searchQuery; // ← TAMBAHKAN INI

  const AllItemsScreen({
    super.key,
    this.filterType = 'All',
    this.searchQuery, // ← TAMBAHKAN INI
  });

  @override
  State<AllItemsScreen> createState() => _AllItemsScreenState();
}


class _AllItemsScreenState extends State<AllItemsScreen> {
  DateTime? _selectedDate;

  // ================= COLORS PALETTE (KONSISTEN) =================
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

  // Logic Date Picker (TETAP SAMA)
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
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: bgPage,
      // 1. APP BAR KONSISTEN
      appBar: AppBar(
        backgroundColor: bgPage,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 18),
          ),
        ),
        title: Text(
          widget.filterType == 'All' ? "All Items" : "${widget.filterType} Items",
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // 2. HEADER & FILTER SECTION
          Container(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Text Style Konsisten
                Text(
                  "Hello, ${user?.namaLengkap ?? 'User'}!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkNavy),
                ),
                const SizedBox(height: 4),
                Text(
                  "Here is the list of ${widget.filterType.toLowerCase()} items.",
                  style: TextStyle(fontSize: 14, color: textGrey),
                ),
                
                const SizedBox(height: 24),

                // Date Filter Row (Style Baru)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Filter by Date:", style: TextStyle(fontWeight: FontWeight.w600, color: textDark, fontSize: 15)),
                    
                    // Date Button (Pill Style - Konsisten dengan MyTask)
                    InkWell(
                      onTap: () => _pickDate(context),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]
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
                                child: Icon(Icons.close_rounded, size: 18, color: errorRed),
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

          // 3. LIST ITEMS
          Expanded(
            child: Consumer<BarangProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator(color: darkNavy));
                }

                // --- LOGIC FILTER (TETAP SAMA) ---
                List<Barang> filteredList = provider.listBarang.where((item) {
                  bool typeMatch = true;
                  if (widget.filterType == 'Lost') typeMatch = item.tipeLaporan == 'hilang';
                  if (widget.filterType == 'Found') typeMatch = item.tipeLaporan == 'ditemukan';

                  bool dateMatch = true;
                  if (_selectedDate != null && item.createdAt != null) {
                    dateMatch = DateUtils.isSameDay(item.createdAt, _selectedDate!);
                  }

                  return typeMatch && dateMatch;
                }).toList();

                filteredList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text("No items found.", style: TextStyle(color: textGrey, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  itemCount: filteredList.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 16), // Jarak antar card
                  itemBuilder: (context, index) {
                    return _buildItemCard(filteredList[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= ITEM CARD (UI DIPERBAIKI) =================
  Widget _buildItemCard(Barang item) {
    bool isLost = item.tipeLaporan == 'hilang';
    String statusText = isLost ? "Lost!!" : "Found!!";
    
    // Warna Tag Status
    Color tagColor = isLost ? warningOrange.withOpacity(0.1) : successGreen.withOpacity(0.1);
    Color tagTextColor = isLost ? warningOrange : successGreen;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => DetailScreen(item: item))
        );
      },
      child: Container(
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
            // 1. FOTO BARANG (KIRI) - Konsisten 70x80
            Container(
              width: 70,
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
                  ? const Center(child: Icon(Icons.assignment_outlined, color: Colors.white, size: 30))
                  : null,
            ),

            const SizedBox(width: 16),

            // 2. DETAIL TEXT (KANAN)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      // Badge Kategori Kecil (Opsional - Pemanis UI)
                      if (item.kategori?.namaKategori != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: bgPage,
                            borderRadius: BorderRadius.circular(6)
                          ),
                          child: Text(
                            item.kategori!.namaKategori,
                            style: TextStyle(fontSize: 10, color: textGrey, fontWeight: FontWeight.bold),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Nama Barang (Row dengan Icon)
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 16, color: textDark),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.namaBarang,
                          style: TextStyle(fontSize: 14, color: textDark, fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),

                  // Lokasi (Row dengan Icon)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: textGrey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.lokasi?.namaLokasi ?? "Lokasi tidak diketahui",
                          style: TextStyle(fontSize: 12, color: textGrey),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Panah Kecil (Pemanis UI)
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}