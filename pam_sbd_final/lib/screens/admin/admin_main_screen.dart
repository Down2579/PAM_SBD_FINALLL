import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers.dart';
import 'manage_items_page.dart';
import 'manage_klaim_page.dart';
import 'manage_kategori_page.dart';
import 'manage_lokasi_page.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final Color bgPage = const Color(0xFFF5F7FA);
  final Color darkNavy = const Color(0xFF2B4263);

  @override
  void initState() {
    super.initState();

    /// Load semua data awal admin
    Future.microtask(() {
      Provider.of<BarangProvider>(context, listen: false)
          .fetchBarang(refresh: true);
      Provider.of<GeneralProvider>(context, listen: false)
          .loadMasterData();
      Provider.of<KlaimProvider>(context, listen: false)
          .fetchAllKlaim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const ManageItemsPage(),     // ✅ TAB 1
      const ManageKlaimPage(),     // TAB 2
      const ManageKategoriPage(),  // TAB 3
      const ManageLokasiPage(),    // TAB 4
    ];

    return Scaffold(
      backgroundColor: bgPage,
      body: pages[_currentIndex],

      /// ================= BOTTOM NAV =================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: darkNavy,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded),
              label: "Items",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in_rounded),
              label: "Klaim",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_rounded),
              label: "Kategori",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_rounded),
              label: "Lokasi",
            ),
          ],
        ),
      ),
    );
  }
}
