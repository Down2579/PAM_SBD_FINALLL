import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- PENTING: Untuk membaca data
import 'help_center_screen.dart';

// --- DATA MODEL UNTUK ITEM YANG SELESAI ---
class CompletedItem {
  final bool isLost;
  final String itemName;
  final String completionDate;

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
  // --- PALET WARNA ---
  final Color darkBlue = const Color(0xFF2B4263);
  final Color textDark = const Color(0xFF1F1F1F);
  final Color textLight = const Color(0xFF6D6D6D);
  final Color bgLightGrey = const Color(0xFFF5F5F5);
  final Color completedGreen = const Color(0xFF4CAF50);

  // --- DATA DUMMY ---
  final List<CompletedItem> completedItems = [
    CompletedItem(isLost: true, itemName: "Payung", completionDate: "11/27/2025"),
    CompletedItem(isLost: false, itemName: "Dompet", completionDate: "11/12/2025"),
    CompletedItem(isLost: true, itemName: "Payung", completionDate: "10/07/2025"),
    CompletedItem(isLost: false, itemName: "Dompet", completionDate: "09/22/2025"),
    CompletedItem(isLost: true, itemName: "Charger Laptop", completionDate: "07/21/2025"),
  ];

  // ================= MODIFIKASI DIMULAI DI SINI =================
  String userName = "User"; // Nilai default

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Panggil fungsi ini saat halaman dimuat
  }

  // Fungsi untuk memuat nama pengguna dari penyimpanan lokal
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Cari data dengan kunci 'username', jika tidak ada, gunakan 'User'
    String? savedName = prefs.getString('username');
    if (mounted) { // Pastikan widget masih ada sebelum update state
      setState(() {
        userName = savedName ?? "User"; // Update variabel userName
      });
    }
  }
  // ================= AKHIR MODIFIKASI =================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCustomHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 24),
              Text(
                "Completed!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark),
              ),
              const SizedBox(height: 16),
              Column(
                children: completedItems.map((item) => _buildCompletedItem(item)).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomHeader() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.menu, color: textDark, size: 28),
          IconButton(
            icon: Icon(Icons.notifications_none_outlined, color: textDark, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpCenterScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper widget untuk header "Hello, User!"
  Widget _buildWelcomeHeader() {
    return Row(
      children: [
        SizedBox(
          height: 60,
          width: 60,
          child: Image.asset(
            'assets/images/logo.png',
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.inventory_2_outlined, size: 48, color: darkBlue);
            },
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: "Hello, ",
                style: TextStyle(fontSize: 24, color: textDark, fontWeight: FontWeight.bold),
                // ================= MODIFIKASI DI SINI =================
                // Teks sekarang mengambil dari variabel `userName`
                children: [TextSpan(text: "$userName!", style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold))],
              ),
            ),
            const SizedBox(height: 4),
            Text("Looking for something?", style: TextStyle(color: textLight, fontSize: 14)),
          ],
        )
      ],
    );
  }

  // Helper widget untuk setiap item di daftar
  Widget _buildCompletedItem(CompletedItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgLightGrey,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        // ... sisa kode tidak berubah
        children: [
          Container(
            width: 80,
            height: 90,
            decoration: BoxDecoration(color: darkBlue, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.isLost ? "Lost!!" : "Found!!", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark)),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.inventory_2_outlined, size: 18, color: textLight),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.itemName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textDark), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.calendar_today_outlined, size: 18, color: textLight),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.completionDate, style: TextStyle(fontSize: 13, color: textLight), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(Icons.check_box, color: completedGreen, size: 28),
          ),
        ],
      ),
    );
  }
}