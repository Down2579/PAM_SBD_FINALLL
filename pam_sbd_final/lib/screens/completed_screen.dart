import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- DATA MODEL (DIMODIFIKASI) ---
class CompletedItem {
  final bool isLost;
  final String itemName;
  final DateTime completionDate; // Diubah ke DateTime

  CompletedItem({
    required this.isLost,
    required this.itemName,
    required this.completionDate,
  });
}

class CompletedScreen extends StatefulWidget {
  @override
  _CompletedScreenState createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  // --- PALET WARNA (SESUAI GAMBAR) ---
  final Color darkNavy = const Color(0xFF3A5475);
  final Color textDark = const Color(0xFF1F2937);
  final Color textLight = const Color(0xFF6B7280);
  final Color bgCard = Colors.white;
  final Color completedGreen = const Color(0xFF4CAF50);
  final Color bgTop = const Color(0xFFE3F2FD);
  final Color bgBottom = const Color(0xFFFFFFFF);

  // --- DATA DUMMY ---
  final List<CompletedItem> allCompletedItems = [
    CompletedItem(isLost: true, itemName: "Payung", completionDate: DateTime(2025, 11, 27)),
    CompletedItem(isLost: false, itemName: "Dompet", completionDate: DateTime(2025, 11, 12)),
    CompletedItem(isLost: true, itemName: "Payung", completionDate: DateTime(2025, 10, 7)),
    CompletedItem(isLost: false, itemName: "Dompet", completionDate: DateTime(2025, 9, 22)),
    CompletedItem(isLost: true, itemName: "Charger Laptop", completionDate: DateTime(2025, 7, 21)),
  ];
  
  // --- STATE ---
  DateTime? _selectedDate;
  List<CompletedItem> _filteredItems = [];
  String userName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _filteredItems = allCompletedItems;
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedName = prefs.getString('username');
    if (mounted) {
      setState(() {
        userName = savedName ?? "User";
      });
    }
  }

  void _filterItems() {
    setState(() {
      if (_selectedDate == null) {
        _filteredItems = allCompletedItems;
      } else {
        _filteredItems = allCompletedItems.where((item) {
          return DateUtils.isSameDay(item.completionDate, _selectedDate);
        }).toList();
      }
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        if (_selectedDate != null && DateUtils.isSameDay(picked, _selectedDate)) {
          _selectedDate = null;
        } else {
          _selectedDate = picked;
        }
        _filterItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgTop, bgBottom],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 20.0),
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 24),
          _buildFilterSection(),
          const SizedBox(height: 16),
          if (_filteredItems.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: _filteredItems.map((item) => _buildCompletedItem(item)).toList(),
            ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildWelcomeHeader() {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 60,
          width: 60,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.inventory_2_outlined, size: 48, color: textLight);
          },
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: "Hello, ",
                style: TextStyle(fontSize: 24, color: textDark, fontWeight: FontWeight.bold),
                children: [TextSpan(text: "$userName!", style: TextStyle(color: darkNavy, fontWeight: FontWeight.bold))],
              ),
            ),
            const SizedBox(height: 4),
            Text("Looking for something?", style: TextStyle(color: textLight, fontSize: 14)),
          ],
        )
      ],
    );
  }
  
  Widget _buildFilterSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Completed!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark)),
        const SizedBox(width: 16),
        InkWell(
          onTap: () => _pickDate(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: textDark),
                const SizedBox(width: 8),
                Text(
                  _selectedDate == null ? 'select date' : DateFormat('MM/dd/yyyy').format(_selectedDate!),
                  style: TextStyle(fontWeight: FontWeight.w600, color: textDark),
                ),
                Icon(Icons.arrow_drop_down, color: textDark),
              ],
            ),
          ),
        )
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: Center(
        child: Text(
          "No completed items found for this date.",
          style: TextStyle(fontSize: 16, color: textLight),
        ),
      ),
    );
  }

  // ### MODIFIKASI UTAMA DI SINI: Tampilan Kartu Sesuai Gambar ###
  Widget _buildCompletedItem(CompletedItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Row(
        children: [
          // 1. Kotak Ikon Biru Gelap
          Container(
            width: 80,
            height: 90,
            decoration: BoxDecoration(color: darkNavy, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.playlist_add_check_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 16),
          // 2. Konten Tengah
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.isLost ? "Lost!!" : "Found!!", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark)),
                const SizedBox(height: 12),
                _buildIconText(Icons.inventory_2_outlined, item.itemName),
                const SizedBox(height: 6),
                _buildIconText(Icons.calendar_today_outlined, DateFormat('MM/dd/yyyy').format(item.completionDate)),
              ],
            ),
          ),
          // 3. Ikon Centang Hijau di Kanan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(Icons.check_box, color: completedGreen, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: textLight),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}