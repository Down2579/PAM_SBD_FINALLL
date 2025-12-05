import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';
import '../api_service.dart';
import '../notification_provider.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';
import 'my_task_screen.dart';
import 'all_items_screen.dart';
import 'completed_screen.dart';
import 'help_center_screen.dart';
import 'search_items_screen.dart';
import '../widgets/notification_modal.dart';
import 'add_item_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int bottomIndex; 
  String userName = "User";
  final ApiService api = ApiService();

  // Palet Warna - Consistent dengan LoginScreen
  final Color primaryBg = const Color(0xFFF5F7FA);
  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);
  final Color textSecondary = const Color(0xFF6B7280);
  final Color successGreen = const Color(0xFF10B981);
  final Color errorRed = const Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    bottomIndex = widget.initialIndex;
    _loadUserData();
    
    // Fetch real notifications dari backend
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedName = prefs.getString('username');
      if (mounted && savedName != null && savedName.isNotEmpty) {
        setState(() => userName = savedName);
      }
    } catch (e) {
      print("Error mengambil data user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildDashboardPage(),
      MyTaskScreen(),
      CompletedScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: bottomIndex,
        children: screens,
      ),
      // ### MODIFIKASI UTAMA DI SINI ###
      floatingActionButton: bottomIndex == 1 // Tampilkan hanya jika tab 'My Task' (indeks 1) aktif
        ? FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddItemScreen()),
              );
            },
            backgroundColor: darkNavy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 35),
          )
        : null, // Jangan tampilkan FAB di tab lain
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomIndex,
        onTap: (index) => setState(() => bottomIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: darkNavy,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "My Task"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: "Completed"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildDashboardPage() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: textDark, size: 28),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HelpCenterScreen())),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Consumer<NotificationProvider>(
              builder: (context, notificationProvider, child) {
                return GestureDetector(
                  onTap: () async {
                    notificationProvider.reset();
                    await showNotificationsModal(context);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.notifications_none_outlined, color: textDark, size: 28),
                      if (notificationProvider.unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            child: Center(
                              child: Text(
                                '${notificationProvider.unreadCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: _buildDashboardContent(),
    );
  }

  // ... (Sisa kode Anda tidak perlu diubah, saya sertakan lagi untuk kelengkapan)

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 24),
          _buildSearchBar(),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildTabButton("My task", 0),
              const SizedBox(width: 15),
              _buildTabButton("All", 1),
            ],
          ),
          const SizedBox(height: 24),
          _buildSummaryCards(),
          const SizedBox(height: 30),
          Text("New", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark)),
          const SizedBox(height: 16),
          _buildFutureList(api.getAllItems()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchItemsScreen()),
        );
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_outlined, color: accentBlue, size: 22),
            const SizedBox(width: 12),
            Text(
              "Search items...",
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const Spacer(),
            Icon(Icons.tune_outlined, color: accentBlue, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Row(
      children: [
        SizedBox(height: 60, width: 60, child: Image.asset('assets/images/logo.png', errorBuilder: (c, e, s) => const Icon(Icons.inventory_2_outlined, size: 48))),
        const SizedBox(width: 12),
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
            Text("Looking for something?", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        )
      ],
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isActive = (index == 0 && bottomIndex == 1);
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          setState(() => bottomIndex = 1);
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AllItemsScreen(filterType: "All")));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : primaryBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive ? [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)] : null,
        ),
        child: Text(text, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard("Found", "19", Icons.inventory_2_outlined, false)),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard("Lost", "17", Icons.search_off_outlined, true)),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon, bool isBoxedIcon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AllItemsScreen(filterType: title)));
      },
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              title == "Lost" ? errorRed : successGreen,
              title == "Lost" ? errorRed.withOpacity(0.7) : successGreen.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (title == "Lost" ? errorRed : successGreen).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white.withOpacity(0.9), size: 50),
                Text(
                  count,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFutureList(Future<List<Item>> future) {
    return FutureBuilder<List<Item>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.only(top: 20), child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("No items found.", style: TextStyle(color: Colors.grey))));
        }
        
        final items = snapshot.data!;
        return Column(children: items.map((item) => _buildListItem(item)).toList());
      },
    );
  }

  Widget _buildListItem(Item item) {
    bool isLost = item.tipeLaporan?.toLowerCase() == "hilang";
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(item: item)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // Image/Icon Container
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    darkNavy,
                    accentBlue,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  isLost ? Icons.search_off_outlined : Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLost
                          ? errorRed.withOpacity(0.15)
                          : successGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isLost ? "Lost" : "Found",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isLost ? errorRed : successGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Item Name
                  Text(
                    item.namaBarang,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildIconText(Icons.location_on_outlined, item.lokasi ?? "-", fontSize: 13),
                ],
              ),
            ),
            // Arrow
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, {double fontSize = 14}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize, color: textDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}