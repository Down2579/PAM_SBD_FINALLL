import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart'; // Pastikan path ini benar
import '../models.dart';
import 'detail_screen.dart'; // Pastikan sudah ada/dibuat
import 'add_item_screen.dart'; // Pastikan sudah ada/dibuat

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // ================= COLORS PALETTE =================
  final Color bgColor = const Color(0xFFF5F7FA);
  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGrey = const Color(0xFF9CA3AF);
  final Color successGreen = const Color(0xFF10B981);
  final Color errorRed = const Color(0xFFEF4444);
  final Color warningOrange = const Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    // Fetch data barang saat pertama kali buka Home
    Future.microtask(() {
      Provider.of<BarangProvider>(context, listen: false).fetchBarang(refresh: true);
      Provider.of<GeneralProvider>(context, listen: false).loadNotifikasi();
    });
  }

  @override
  Widget build(BuildContext context) {
    // List halaman untuk Bottom Navigation
    final List<Widget> pages = [
      _buildDashboard(context), // Halaman Utama sesuai screenshot
      const Center(child: Text("My Task Page")), // Placeholder
      const Center(child: Text("Completed Page")), // Placeholder
      const Center(child: Text("Profile Page")), // Placeholder
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: pages[_currentIndex],
      
      // Floating Action Button hanya di Home atau My Task
      floatingActionButton: _currentIndex <= 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddItemScreen()),
                );
              },
              backgroundColor: darkNavy,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: darkNavy,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: false, // Style modern tanpa label
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 28), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded, size: 28), label: "Task"),
            BottomNavigationBarItem(icon: Icon(Icons.check_circle_rounded, size: 28), label: "Done"),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 28), label: "Profile"),
          ],
        ),
      ),
    );
  }

  // ================= DASHBOARD WIDGET =================
  Widget _buildDashboard(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Menu & Notif)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.menu_rounded, size: 28, color: textDark),
                Stack(
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 28, color: textDark),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
            
            const SizedBox(height: 24),

            // 2. Welcome Text & Logo
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                    ]
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "Hello, \n",
                        style: TextStyle(fontSize: 16, color: textGrey, fontWeight: FontWeight.w500),
                        children: [
                          TextSpan(
                            text: user?.namaLengkap ?? "Guest",
                            style: TextStyle(
                              fontSize: 20, 
                              color: textDark, 
                              fontWeight: FontWeight.bold,
                              height: 1.2
                            ),
                          )
                        ]
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 3. Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0,5))
                ]
              ),
              child: TextField(
                onSubmitted: (value) {
                  // Panggil Provider search
                  Provider.of<BarangProvider>(context, listen: false).fetchBarang(search: value, refresh: true);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search items...",
                  hintStyle: TextStyle(color: textGrey),
                  icon: Icon(Icons.search_rounded, color: textGrey),
                  suffixIcon: Icon(Icons.filter_list_rounded, color: darkNavy),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 4. Filter Tabs (My Task / All)
            Row(
              children: [
                _buildTabPill("My task", false),
                const SizedBox(width: 12),
                _buildTabPill("All", true),
              ],
            ),

            const SizedBox(height: 24),

            // 5. Big Cards (Found / Lost)
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Found",
                    icon: Icons.check_rounded,
                    color: darkNavy,
                    bgIcon: Icons.check_circle_outline,
                    onTap: () {
                      // Filter barang ditemukan
                      Provider.of<BarangProvider>(context, listen: false).fetchBarang(type: 'ditemukan', refresh: true);
                    }
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: "Lost",
                    icon: Icons.question_mark_rounded,
                    color: darkNavy,
                    bgIcon: Icons.help_outline_rounded,
                    onTap: () {
                      // Filter barang hilang
                      Provider.of<BarangProvider>(context, listen: false).fetchBarang(type: 'hilang', refresh: true);
                    }
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 6. Recent Items Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Items",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                ),
                GestureDetector(
                  onTap: () {
                     // Reset filter
                     Provider.of<BarangProvider>(context, listen: false).fetchBarang(refresh: true);
                  },
                  child: Text("See All", style: TextStyle(color: accentBlue, fontWeight: FontWeight.w600)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 7. List Items (Consumer dari BarangProvider)
            Consumer<BarangProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                }
                
                if (provider.listBarang.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox_rounded, size: 50, color: textGrey),
                        const SizedBox(height: 10),
                        Text("No items found", style: TextStyle(color: textGrey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true, // Agar bisa scroll di dalam SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.listBarang.length > 5 ? 5 : provider.listBarang.length, // Limit 5 items
                  itemBuilder: (context, index) {
                    final item = provider.listBarang[index];
                    return _buildListItem(item);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPER WIDGETS =================

  Widget _buildTabPill(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        boxShadow: isActive ? [
           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ] : null
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? textDark : textGrey,
          fontWeight: FontWeight.bold,
          fontSize: 14
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required Color color,
    required IconData bgIcon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
          ]
        ),
        child: Stack(
          children: [
            // Background Icon Faded
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(bgIcon, size: 120, color: Colors.white.withOpacity(0.1)),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                  )
                ],
              ),
            ),
            
            // Big Check/Question Icon in Center
            Center(
               child: Icon(bgIcon, size: 40, color: Colors.white.withOpacity(0.2)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(Barang item) {
    bool isLost = item.tipeLaporan == 'hilang';
    Color statusColor = isLost ? warningOrange : successGreen;
    String statusText = isLost ? "LOST" : "FOUND";

    // Handle Image
    Widget imageWidget;
    if (item.gambarUrl != null && item.gambarUrl!.isNotEmpty) {
      imageWidget = Image.network(
        item.gambarUrl!, // Pastikan logic getter di model sudah handle full URL
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => Icon(Icons.image_not_supported, color: Colors.white.withOpacity(0.5)),
      );
    } else {
      imageWidget = Icon(
        isLost ? Icons.search_off_rounded : Icons.inventory_2_rounded,
        color: Colors.white,
        size: 32,
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(item: item)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))
          ]
        ),
        child: Row(
          children: [
            // Left Side: Image / Icon Container
            Container(
              width: 80,
              height: 90,
              decoration: BoxDecoration(
                color: darkNavy,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                image: item.gambarUrl != null ? DecorationImage(
                  image: NetworkImage(item.gambarUrl!),
                  fit: BoxFit.cover
                ) : null
              ),
              child: item.gambarUrl == null ? Center(child: imageWidget) : null,
            ),
            
            // Right Side: Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "$statusText • ${item.status.toUpperCase()}",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.namaBarang,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 14, color: textGrey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.lokasi?.namaLokasi ?? "Unknown Location",
                            style: TextStyle(fontSize: 12, color: textGrey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: textGrey),
            )
          ],
        ),
      ),
    );
  }
}