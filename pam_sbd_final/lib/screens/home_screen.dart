import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart';
import '../models.dart';
import 'detail_screen.dart';
import 'all_items_screen.dart';
import 'my_task_screen.dart'; // ✅ Pastikan file ini ada dan diimport

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // ================= COLORS PALETTE =================
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color darkNavy = const Color(0xFF2B4263);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGrey = const Color(0xFF9CA3AF);
  final Color successGreen = const Color(0xFF10B981);
  final Color warningOrange = const Color(0xFFF59E0B);

  // Base URL Image
  final String baseUrlImage = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BarangProvider>(context, listen: false).fetchBarang(refresh: true);
      Provider.of<GeneralProvider>(context, listen: false).loadNotifikasi();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ LIST HALAMAN UNTUK BOTTOM NAV
    final List<Widget> pages = [
      _buildDashboard(context), // Index 0: Home Dashboard
      const MyTaskScreen(),     // Index 1: My Task Screen (Halaman User)
      const Center(child: Text("Done Page")), // Index 2: Done (Placeholder)
      const Center(child: Text("Profile Page")), // Index 3: Profile (Placeholder)
    ];

    return Scaffold(
      backgroundColor: bgPage,
      
      // Menampilkan halaman sesuai index yang dipilih
      body: pages[_currentIndex],
      
      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: darkNavy,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 28), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined, size: 28), label: "Task"), // ✅ Tombol My Task
            BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline_rounded, size: 28), label: "Done"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded, size: 28), label: "Profile"),
          ],
        ),
      ),
    );
  }

  // ================= DASHBOARD UTAMA (TAB 0) =================
  Widget _buildDashboard(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER (Logo & Sapaan)
            Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.inventory_2_outlined, color: darkNavy, size: 28),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hello, ${user?.namaLengkap ?? 'User'}!", 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkNavy)),
                    Text("Looking for something?", 
                      style: TextStyle(fontSize: 14, color: textGrey)),
                  ],
                ),
                const Spacer(),
                Icon(Icons.notifications_none_rounded, size: 28, color: darkNavy),
              ],
            ),

            const SizedBox(height: 24),

            // 2. TOMBOL NAVIGASI (My Task & All)
            Row(
              children: [
                // Tombol My Task (Shortcut ke Tab 1)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // ✅ Ubah index ke 1 (Tab My Task)
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: darkNavy,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: const Text("My Task", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Tombol All (Pindah Halaman Baru)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const AllItemsScreen(filterType: 'All'))
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: darkNavy,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: const Text("All", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 3. STATISTIK (FOUND / LOST)
            Consumer<BarangProvider>(
              builder: (context, provider, _) {
                int foundCount = provider.listBarang.where((i) => i.tipeLaporan == 'ditemukan').length;
                int lostCount = provider.listBarang.where((i) => i.tipeLaporan == 'hilang').length;

                return Row(
                  children: [
                    _buildStatCard("Found", foundCount, darkNavy, Icons.check_box_outline_blank_rounded),
                    const SizedBox(width: 16),
                    _buildStatCard("Lost", lostCount, darkNavy, Icons.close_rounded),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            // 4. LIST DATA BARANG (New Items)
            const Text("New Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Consumer<BarangProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.listBarang.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 50, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text("Belum ada barang", style: TextStyle(color: textGrey)),
                      ],
                    ),
                  );
                }

                final displayList = provider.listBarang.take(5).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    return _buildItemCard(context, displayList[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= ITEM CARD =================
  Widget _buildItemCard(BuildContext context, Barang item) {
    bool isLost = item.tipeLaporan == 'hilang';
    String statusText = isLost ? "Lost!!" : "Found!!";
    
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(item: item)));
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

            // 2. INFO BARANG (KANAN)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 18, color: textDark),
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

                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 18, color: textDark),
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

  // ================= STAT CARD =================
  Widget _buildStatCard(String title, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: Colors.white),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                title, 
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                count.toString(), 
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
      ),
    );
  }
}