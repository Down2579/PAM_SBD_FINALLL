import 'dart:async'; // Untuk Timer (Debounce)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers.dart';
import 'detail_screen.dart';

class SearchItemsScreen extends StatefulWidget {
  const SearchItemsScreen({super.key});

  @override
  State<SearchItemsScreen> createState() => _SearchItemsScreenState();
}

class _SearchItemsScreenState extends State<SearchItemsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  // Filter States
  String? _selectedType; // 'hilang' | 'ditemukan' | null
  DateTime? _selectedDate;

  // Colors Palette
  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGrey = const Color(0xFF9CA3AF);
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color borderGrey = const Color(0xFFE5E7EB);
  final Color errorRed = const Color(0xFFEF4444);
  final Color successGreen = const Color(0xFF10B981);
  final Color warningOrange = const Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    // Load initial data (kosong atau semua)
    Future.microtask(() => _performSearch());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Logic Pencarian Utama
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // Tunggu 500ms setelah user berhenti mengetik baru panggil API
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  void _performSearch() {
    // Panggil Provider untuk fetch data dari server berdasarkan Text & Tipe
    Provider.of<BarangProvider>(context, listen: false).fetchBarang(
      search: _searchController.text,
      type: _selectedType,
      refresh: true, // Reset list
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedType = null;
      _selectedDate = null;
    });
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: bgPage,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Search Items", 
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        actions: [
          if(_searchController.text.isNotEmpty || _selectedType != null || _selectedDate != null)
            TextButton(
              onPressed: _clearFilters,
              child: Text("Reset", style: TextStyle(color: errorRed, fontWeight: FontWeight.bold)),
            )
        ],
      ),
      body: Column(
        children: [
          // ================= SEARCH & FILTERS HEADER =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: bgPage,
            child: Column(
              children: [
                // 1. Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderGrey),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,4))
                    ]
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Search name, location...",
                      hintStyle: TextStyle(color: textGrey, fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded, color: darkNavy),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded, size: 18, color: textGrey),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: _selectedType == null 
                            ? "Type" 
                            : (_selectedType == 'hilang' ? "Lost" : "Found"),
                        isActive: _selectedType != null,
                        icon: Icons.filter_list_rounded,
                        onTap: _showTypeFilterModal,
                      ),
                      const SizedBox(width: 10),
                      _buildFilterChip(
                        label: _selectedDate == null 
                            ? "Date" 
                            : DateFormat('dd MMM').format(_selectedDate!),
                        isActive: _selectedDate != null,
                        icon: Icons.calendar_today_rounded,
                        onTap: _pickDate,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ================= RESULT LIST =================
          Expanded(
            child: Consumer<BarangProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator(color: darkNavy));
                }

                // Filter Tanggal dilakukan di Client Side (karena API belum tentu support range date)
                // Kita ambil list dari provider, lalu filter lokal
                List<Barang> displayList = provider.listBarang;

                if (_selectedDate != null) {
                  displayList = displayList.where((item) {
                    if (item.tanggalKejadian == null) return false;
                    return DateUtils.isSameDay(item.tanggalKejadian!, _selectedDate!);
                  }).toList();
                }

                if (displayList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "No items found",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Try adjusting your filters",
                          style: TextStyle(color: textGrey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    return _buildItemCard(displayList[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPER WIDGETS =================

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? darkNavy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? darkNavy : borderGrey),
          boxShadow: isActive 
             ? [BoxShadow(color: darkNavy.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
             : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : textGrey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : textDark,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.white),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(Barang item) {
    bool isLost = item.tipeLaporan == "hilang";
    Color statusColor = isLost ? warningOrange : successGreen;
    String statusText = isLost ? "LOST" : "FOUND";

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(item: item)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Strip Indicator
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: isLost ? errorRed : successGreen,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                ),
              ),
              
              // Icon Box
              Container(
                width: 70,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [darkNavy, darkNavy.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  image: item.gambarUrl != null 
                      ? DecorationImage(image: NetworkImage(item.gambarUrl!), fit: BoxFit.cover)
                      : null
                ),
                child: item.gambarUrl == null 
                    ? Icon(isLost ? Icons.search_off_outlined : Icons.inventory_2_outlined, color: Colors.white, size: 30)
                    : null,
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badges
                      Row(
                        children: [
                          _buildMiniBadge(statusText, isLost ? errorRed : successGreen),
                          const SizedBox(width: 8),
                          if(item.status != 'open')
                            _buildMiniBadge(item.status.toUpperCase(), Colors.grey, isOutline: true),
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      Text(
                        item.namaBarang,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 12, color: textGrey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.lokasi?.namaLokasi ?? "-",
                              style: TextStyle(fontSize: 12, color: textGrey),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Arrow
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color, {bool isOutline = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isOutline ? color : Colors.transparent),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  // ================= LOGIC HANDLERS =================

  void _showTypeFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Filter by Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
              const SizedBox(height: 20),
              _buildTypeOption("All Types", null),
              _buildTypeOption("Lost Items", "hilang"),
              _buildTypeOption("Found Items", "ditemukan"),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTypeOption(String label, String? value) {
    bool isSelected = _selectedType == value;
    return ListTile(
      title: Text(
        label, 
        style: TextStyle(
          color: isSelected ? accentBlue : textDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
        )
      ),
      trailing: isSelected ? Icon(Icons.check, color: accentBlue) : null,
      onTap: () {
        setState(() => _selectedType = value);
        Navigator.pop(context);
        _performSearch();
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: darkNavy),
          ),
          child: child!,
        );
      }
    );
    if (picked != null) {
      // Logic Toggle: Jika tanggal sama dipilih lagi -> batalkan filter
      if (_selectedDate != null && DateUtils.isSameDay(picked, _selectedDate!)) {
        setState(() => _selectedDate = null);
      } else {
        setState(() => _selectedDate = picked);
      }
      // Kita tidak panggil _performSearch() disini karena date filter dilakukan client side di builder ListView
    }
  }
}