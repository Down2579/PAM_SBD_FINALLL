import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // DITAMBAHKAN
import 'home_screen.dart';
import 'my_task_screen.dart';
import 'completed_screen.dart';
import 'profile_screen.dart';
import 'help_center_screen.dart';

// --- DATA MODEL ---
class ListItem {
  final bool isLost;
  final String itemName;
  final String location;
  final DateTime date;

  ListItem({
    required this.isLost,
    required this.itemName,
    required this.location,
    required this.date,
  });
}

// --- SCREEN WIDGET ---
class AllItemsScreen extends StatefulWidget {
  final String filterType;

  const AllItemsScreen({Key? key, required this.filterType}) : super(key: key);

  @override
  _AllItemsScreenState createState() => _AllItemsScreenState();
}

class _AllItemsScreenState extends State<AllItemsScreen> {
  // --- DATA DUMMY ---
  final List<ListItem> allItems = [
    ListItem(isLost: true, itemName: "Payung", location: "Kb lantai 1", date: DateTime.now()),
    ListItem(isLost: false, itemName: "Dompet", location: "EH", date: DateTime.now().subtract(Duration(days: 1))),
    ListItem(isLost: true, itemName: "Kunci Motor", location: "Kb lantai 1", date: DateTime.now().subtract(Duration(days: 1))),
    ListItem(isLost: false, itemName: "Dompet", location: "EH", date: DateTime.now().subtract(Duration(days: 2))),
    ListItem(isLost: true, itemName: "Charger Laptop", location: "GD 525", date: DateTime.now().subtract(Duration(days: 5))),
    ListItem(isLost: false, itemName: "Charger Handphone", location: "GD 525", date: DateTime.now().subtract(Duration(days: 6))),
  ];

  DateTime? _selectedDate;
  List<ListItem> _filteredItems = [];
  int _bottomNavIndex = 0;

  // ### MODIFIKASI 1: Variabel untuk menyimpan nama user ###
  String userName = "User";

  // --- PALET WARNA ---
  final Color darkNavy = const Color(0xFF1e293b);
  final Color accentBlue = const Color(0xFF3b82f6);
  final Color primaryPurple = const Color(0xFF7c3aed);
  final Color textDark = const Color(0xFF1F2937);
  final Color textLight = const Color(0xFF6D6D6D);
  final Color bgLightGrey = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    // ### MODIFIKASI 2: Panggil fungsi untuk memuat data user ###
    _loadUserData();
    _filterItems();
  }

  // ### MODIFIKASI 3: Fungsi untuk memuat nama dari SharedPreferences ###
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Cari data dengan kunci 'username', jika tidak ada, gunakan 'User'
    String? savedName = prefs.getString('username');
    if (mounted) {
      setState(() {
        userName = savedName ?? "User";
      });
    }
  }

  void _filterItems() {
    List<ListItem> tempItems;
    if (widget.filterType == 'Lost') {
      tempItems = allItems.where((item) => item.isLost).toList();
    } else if (widget.filterType == 'Found') {
      tempItems = allItems.where((item) => !item.isLost).toList();
    } else {
      tempItems = allItems;
    }
    if (_selectedDate != null) {
      tempItems = tempItems.where((item) => DateUtils.isSameDay(item.date, _selectedDate)).toList();
    }
    setState(() {
      _filteredItems = tempItems;
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
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
          _buildFilterSection(),
          const SizedBox(height: 16),
          if (_filteredItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: Center(
                child: Text(
                  "No items found for this filter.",
                  style: TextStyle(fontSize: 16, color: textLight),
                ),
              ),
            )
          else
            Column(
              children: _filteredItems.map((item) => _buildListItem(item)).toList(),
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
        selectedItemColor: darkNavy,
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
                // ### MODIFIKASI 4: Gunakan variabel userName ###
                children: [TextSpan(text: "$userName!", style: TextStyle(color: darkNavy, fontWeight: FontWeight.bold))],
              ),
            ),
            const SizedBox(height: 4),
            Text("Looking for something?", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        )
      ],
    );
  }

  Widget _buildFilterSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(widget.filterType, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark)),
        const SizedBox(width: 16),
        InkWell(
          onTap: () => _pickDate(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2))],
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
            decoration: BoxDecoration(color: darkNavy, borderRadius: BorderRadius.circular(16)),
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