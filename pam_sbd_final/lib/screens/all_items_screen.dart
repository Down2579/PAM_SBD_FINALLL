import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'my_task_screen.dart';
import 'completed_screen.dart';
import 'profile_screen.dart';
import 'help_center_screen.dart';

// --- DATA MODEL SEDERHANA ---
class ListItem {
  final bool isLost;
  final String itemName;
  final String location;

  ListItem({
    required this.isLost,
    required this.itemName,
    required this.location,
  });
}

// --- SCREEN WIDGET ---
class AllItemsScreen extends StatefulWidget {
  // ### MODIFIKASI: Parameter untuk menerima filter ###
  final String filterType; // Akan berisi "All", "Lost", atau "Found"

  const AllItemsScreen({Key? key, required this.filterType}) : super(key: key);

  @override
  _AllItemsScreenState createState() => _AllItemsScreenState();
}

class _AllItemsScreenState extends State<AllItemsScreen> {
  // --- DATA DUMMY ---
  final List<ListItem> allItems = [
    ListItem(isLost: true, itemName: "Payung", location: "Kb lantai 1"),
    ListItem(isLost: false, itemName: "Dompet", location: "EH"),
    ListItem(isLost: true, itemName: "Payung", location: "Kb lantai 1"),
    ListItem(isLost: false, itemName: "Dompet", location: "EH"),
    ListItem(isLost: true, itemName: "Charger Laptop", location: "GD 525"),
    ListItem(isLost: false, itemName: "Charger Handphone", location: "GD 525"),
  ];

  int _bottomNavIndex = 0;

  // --- PALET WARNA (Sesuai Desain Baru) ---
  final Color darkBlue = const Color(0xFF3A5475);
  final Color textDark = const Color(0xFF1F1F1F);
  final Color textLight = const Color(0xFF6D6D6D);
  final Color bgLightGrey = const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    // ### MODIFIKASI: Logika untuk memfilter daftar item ###
    List<ListItem> filteredItems;

    if (widget.filterType == 'Lost') {
      filteredItems = allItems.where((item) => item.isLost).toList();
    } else if (widget.filterType == 'Found') {
      filteredItems = allItems.where((item) => !item.isLost).toList();
    } else {
      filteredItems = allItems;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        // ### MODIFIKASI: Judul AppBar dinamis ###
        title: Text(
          "${widget.filterType} Items",
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        leading: Icon(Icons.menu, color: textDark, size: 28),
        actions: [
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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 24),
          // ### MODIFIKASI: Judul konten dinamis ###
          Text(
            "${widget.filterType} Items",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark),
          ),
          const SizedBox(height: 16),
          // ### MODIFIKASI: Tampilkan daftar yang sudah difilter ###
          Column(
            children: filteredItems.map((item) => _buildListItem(item)).toList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          else if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyTaskScreen()));
          else if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CompletedScreen()));
          else if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: darkBlue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Task"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: "Completed"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Row(
      children: [
        SizedBox(height: 60, width: 60, child: Image.asset('assets/images/logo.png')),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: "Hello, ",
                style: TextStyle(fontSize: 24, color: textDark, fontWeight: FontWeight.bold),
                children: [TextSpan(text: "User!", style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold))],
              ),
            ),
            const SizedBox(height: 4),
            Text("Looking for something?", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        )
      ],
    );
  }

  Widget _buildListItem(ListItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgLightGrey,
        borderRadius: BorderRadius.circular(20),
      ),
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
                Text(
                  item.isLost ? "Lost!!" : "Found!!",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark),
                ),
                const SizedBox(height: 8),
                _buildIconText(Icons.widgets_outlined, item.itemName),
                const SizedBox(height: 4),
                _buildIconText(Icons.location_on_outlined, item.location),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.more_vert, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        SizedBox(width: 8),
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