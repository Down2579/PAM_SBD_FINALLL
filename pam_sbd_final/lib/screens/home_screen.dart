import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';
import '../api_service.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';
import 'my_task_screen.dart';
import 'all_items_screen.dart';
import 'completed_screen.dart';
import 'help_center_screen.dart';
import 'notification_screen.dart'; // Import halaman Notification

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int bottomIndex = 0;
  String userName = "User";
  final ApiService api = ApiService();

  // Palet Warna
  final Color darkBlue = const Color(0xFF2B4263);
  final Color textDark = const Color(0xFF1F1F1F);
  final Color bgLightGrey = const Color(0xFFF5F5F5);
  final Color buttonGrey = const Color(0xFFE8E8E8);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedName = prefs.getString('username');
      if (savedName != null && savedName.isNotEmpty) {
        setState(() {
          userName = savedName;
        });
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomIndex,
        onTap: (index) {
          setState(() {
            bottomIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: darkBlue,
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
        leading: Icon(Icons.menu, color: textDark, size: 28),
        actions: [
          // ### MODIFIKASI UTAMA DI SINI ###
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // 2. Navigasi diubah ke NotificationScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              },
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  // 1. Ikon lonceng dan badge ditambahkan
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, right: 8.0),
                    child: Icon(
                      Icons.notifications_none_outlined,
                      color: textDark,
                      size: 28,
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(top: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '3', // Angka notifikasi
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
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
          Text(
            "New",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
          ),
          const SizedBox(height: 16),
          _buildFutureList(api.getAllItems()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Row(
      children: [
        SizedBox(height: 60, width: 60, child: Image.asset('assets/images/logo.png', errorBuilder: (c, e, s) => Icon(Icons.inventory_2_outlined, size: 48))),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: "Hello, ",
                style: TextStyle(fontSize: 24, color: textDark, fontWeight: FontWeight.bold),
                children: [TextSpan(text: "$userName!", style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold))],
              ),
            ),
            Text("Looking for something?", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        )
      ],
    );
  }

  Widget _buildTabButton(String text, int index) {
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          setState(() { bottomIndex = 1; });
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AllItemsScreen(filterType: "All")));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(color: buttonGrey, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard("Found", "19", Icons.inventory_2_outlined, false)),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard("Lost", "17", Icons.close, true)),
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
        decoration: BoxDecoration(color: darkBlue, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Expanded(
              child: Center(
                child: isBoxedIcon
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(icon, color: Colors.white, size: 36))
                    : Icon(icon, color: Colors.white, size: 50),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(count, style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 18)),
            )
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
          return Center(child: Padding(padding: EdgeInsets.only(top: 20), child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text("No items found.", style: TextStyle(color: Colors.grey))));
        }
        return Column(children: snapshot.data!.map((item) => _buildListItem(item)).toList());
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bgLightGrey, borderRadius: BorderRadius.circular(20)),
        child: Row(
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
                  Text(isLost ? "Lost!!" : "Found!!", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark)),
                  const SizedBox(height: 8),
                  _buildIconText(Icons.widgets_outlined, item.namaBarang),
                  const SizedBox(height: 4),
                  _buildIconText(Icons.location_on_outlined, item.lokasi ?? "-"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
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