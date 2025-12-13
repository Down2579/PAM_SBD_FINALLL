import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers.dart';
import 'detail_screen.dart';

class AllItemsScreen extends StatefulWidget {
  final String filterType; // 'Lost', 'Found', atau 'All' (default)

  const AllItemsScreen({super.key, this.filterType = 'All'});

  @override
  State<AllItemsScreen> createState() => _AllItemsScreenState();
}

class _AllItemsScreenState extends State<AllItemsScreen> {
  DateTime? _selectedDate;

  // ================= COLORS PALETTE (SAMA DENGAN HOME) =================
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color darkNavy = const Color(0xFF2B4263);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGrey = const Color(0xFF9CA3AF);
  final Color successGreen = const Color(0xFF10B981);
  final Color warningOrange = const Color(0xFFF59E0B);
  final Color errorRed = const Color(0xFFEF4444);

  // Base URL Image (Sesuaikan IP)
  final String baseUrlImage = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    // Pastikan data fresh saat masuk halaman ini
    Future.microtask(() => 
      Provider.of<BarangProvider>(context, listen: false).fetchBarang(refresh: true)
    );
  }

  // Logic Date Picker (Max 3 bulan ke belakang, tidak boleh besok)
  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime threeMonthsAgo = now.subtract(const Duration(days: 90));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: threeMonthsAgo, // Max 3 bulan ke belakang
      lastDate: now,             // Tidak boleh besok
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
    // Ambil user dari AuthProvider
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: bgPage,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 18),
          ),
        ),
        title: Text(
          widget.filterType == 'All' ? "All Items" : "${widget.filterType} Items",
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. HEADER & FILTER SECTION
          Container(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Text
                Text(
                  "Hello, ${user?.namaLengkap ?? 'User'}!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkNavy),
                ),
                const SizedBox(height: 4),
                Text(
                  "Here is the list of ${widget.filterType.toLowerCase()} items.",
                  style: TextStyle(fontSize: 14, color: textGrey),
                ),
                
                const SizedBox(height: 20),

                // Date Filter Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Filter by Date", style: TextStyle(fontWeight: FontWeight.w600, color: textDark, fontSize: 16)),
                    
                    // Date Button
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

          // 2. LIST ITEMS
          Expanded(
            child: Consumer<BarangProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator(color: darkNavy));
                }

                // --- FILTER LOGIC ---
                List<Barang> filteredList = provider.listBarang.where((item) {
                  // 1. Filter by Type (Lost/Found/All)
                  bool typeMatch = true;
                  if (widget.filterType == 'Lost') typeMatch = item.tipeLaporan == 'hilang';
                  if (widget.filterType == 'Found') typeMatch = item.tipeLaporan == 'ditemukan';

                  // 2. Filter by Date (If selected)
                  bool dateMatch = true;
                  if (_selectedDate != null && item.createdAt != null) {
                    // Menggunakan createdAt sebagai patokan tanggal
                    dateMatch = DateUtils.isSameDay(item.createdAt, _selectedDate!);
                  }

                  return typeMatch && dateMatch;
                }).toList();

                // Sort by Latest
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

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  itemCount: filteredList.length,
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

  // ================= ITEM CARD (SAMA PERSIS DENGAN HOME) =================
  Widget _buildItemCard(Barang item) {
    bool isLost = item.tipeLaporan == 'hilang';
    String statusText = isLost ? "Lost!!" : "Found!!";

    return GestureDetector(
      onTap: () {
        // Navigasi ke Detail
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
              width: 70,
              height: 70,
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
                  // Judul Status (Lost!! / Found!!)
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
                      // Badge Status Proses (Optional)
                      if(item.status != 'open')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            item.status.toUpperCase(), 
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textGrey)
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Nama Barang
                  Row(
                    children: [
                      Icon(Icons.layers_outlined, size: 16, color: textDark),
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

                  // Lokasi
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: textDark),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.lokasi?.namaLokasi ?? "Lokasi tidak diketahui",
                          style: TextStyle(fontSize: 13, color: textDark),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}