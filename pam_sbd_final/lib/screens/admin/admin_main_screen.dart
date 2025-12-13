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
    // DAFTAR HALAMAN (Termasuk Halaman Akun Baru)
    final List<Widget> pages = [
      const ManageItemsPage(),     // Tab 0
      const ManageKlaimPage(),     // Tab 1
      const ManageKategoriPage(),  // Tab 2
      const ManageLokasiPage(),    // Tab 3
      const AdminAccountPage(),    // Tab 4 (Halaman Akun & Logout)
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
          selectedFontSize: 12,
          unselectedFontSize: 12,
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
            // ITEM BARU UNTUK AKUN/LOGOUT
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: "Akun",
            ),
          ],
        ),
      ),
    );
  }
}

/// =========================================================
/// HALAMAN BARU KHUSUS PROFIL & LOGOUT ADMIN
/// =========================================================
class AdminAccountPage extends StatelessWidget {
  const AdminAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    const Color darkNavy = Color(0xFF2B4263);
    const Color errorRed = Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Profil Admin", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: darkNavy,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar Icon
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: darkNavy.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, size: 50, color: darkNavy),
              ),
              const SizedBox(height: 24),
              
              // Nama & Info
              Text(
                user?.namaLengkap ?? "Administrator",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkNavy),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? "admin@example.com",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Tombol Logout
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _handleLogout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: const Text("Keluar Aplikasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    // Tampilkan konfirmasi
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Keluar"),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Keluar", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm && context.mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      
      if (context.mounted) {
        // Kembali ke halaman Login (Route '/')
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }
}