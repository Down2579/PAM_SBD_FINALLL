import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';
import '../models.dart';
import 'detail_screen.dart';
import 'home_screen.dart';
import 'my_task_screen.dart';
import 'completed_screen.dart';
import 'profile_screen.dart';

class SearchItemsScreen extends StatefulWidget {
  const SearchItemsScreen({Key? key}) : super(key: key);

  @override
  State<SearchItemsScreen> createState() => _SearchItemsScreenState();
}

class _SearchItemsScreenState extends State<SearchItemsScreen> {
  final ApiService api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Item> _allItems = [];
  List<Item> _filteredItems = [];
  bool _isLoading = true;

  String? _selectedType; // "hilang" / "ditemukan" / null
  DateTime? _selectedDate;

  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);
  final Color textSecondary = const Color(0xFF6B7280);
  final Color bgGrey = const Color(0xFFF5F7FA);
  final Color borderGrey = const Color(0xFFE5E7EB);
  final Color errorRed = const Color(0xFFEF4444);
  final Color successGreen = const Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    try {
      final items = await api.getAllItems();
      setState(() {
        _allItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading items: $e");
      setState(() => _isLoading = false);
    }
  }

  void _performSearch() {
    _applyFilters();
  }

  void _applyFilters() {
    List<Item> results = _allItems;

    // Filter by search text
    if (_searchController.text.isNotEmpty) {
      String query = _searchController.text.toLowerCase();
      results = results
          .where((item) =>
              item.namaBarang.toLowerCase().contains(query) ||
              (item.deskripsi?.toLowerCase().contains(query) ?? false) ||
              (item.lokasi?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    // Filter by type
    if (_selectedType != null) {
      results = results
          .where((item) => item.tipeLaporan.toLowerCase() == _selectedType)
          .toList();
    }

    // Filter by date
    if (_selectedDate != null) {
      results = results
          .where((item) {
            try {
              DateTime itemDate = DateTime.parse(item.waktu);
              return DateUtils.isSameDay(itemDate, _selectedDate!);
            } catch (e) {
              return false;
            }
          })
          .toList();
    }

    setState(() => _filteredItems = results);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (_selectedDate != null && DateUtils.isSameDay(picked, _selectedDate!)) {
          _selectedDate = null; // Toggle off
        } else {
          _selectedDate = picked;
        }
        _applyFilters();
      });
    }
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedType = null;
      _selectedDate = null;
      _filteredItems = _allItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Search Items", style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search by name, location...",
                    hintStyle: TextStyle(color: textSecondary),
                    prefixIcon: Icon(Icons.search, color: darkNavy),
                    filled: true,
                    fillColor: bgGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderGrey, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderGrey, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: darkNavy, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Type Filter
                      FilterChip(
                        label: Text(
                          _selectedType == null ? "All Types" : _selectedType == "hilang" ? "Lost" : "Found",
                          style: TextStyle(
                            color: _selectedType == null ? textSecondary : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: _selectedType == null ? bgGrey : darkNavy,
                        side: BorderSide(
                          color: _selectedType == null ? borderGrey : darkNavy,
                        ),
                        onSelected: (_) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Filter by Type"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: const Text("All Types"),
                                    onTap: () {
                                      setState(() => _selectedType = null);
                                      _applyFilters();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text("Lost"),
                                    onTap: () {
                                      setState(() => _selectedType = "hilang");
                                      _applyFilters();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text("Found"),
                                    onTap: () {
                                      setState(() => _selectedType = "ditemukan");
                                      _applyFilters();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),

                      // Date Filter
                      FilterChip(
                        label: Text(
                          _selectedDate == null ? "All Dates" : DateFormat("MM/dd").format(_selectedDate!),
                          style: TextStyle(
                            color: _selectedDate == null ? textSecondary : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: _selectedDate == null ? bgGrey : darkNavy,
                        side: BorderSide(
                          color: _selectedDate == null ? borderGrey : darkNavy,
                        ),
                        onSelected: (_) => _pickDate(),
                      ),
                      const SizedBox(width: 8),

                      // Clear Filters
                      if (_searchController.text.isNotEmpty || _selectedType != null || _selectedDate != null)
                        ActionChip(
                          label: const Text("Clear", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                          backgroundColor: Colors.red.withOpacity(0.1),
                          side: const BorderSide(color: Colors.red),
                          onPressed: _clearFilters,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: darkNavy))
                : _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              "No items found",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Try adjusting your filters",
                              style: TextStyle(color: textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) => _buildItemCard(_filteredItems[index]),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Task"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: "Completed"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildItemCard(Item item) {
    bool isLost = item.tipeLaporan.toLowerCase() == "hilang";
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(item: item)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderGrey, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [darkNavy, darkNavy.withOpacity(0.7)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Icon(
                isLost ? Icons.search_off_outlined : Icons.inventory_2_outlined,
                color: Colors.white,
                size: 38,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.namaBarang,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.lokasi ?? "-",
                            style: TextStyle(fontSize: 12, color: textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat("MM/dd/yyyy").format(DateTime.parse(item.waktu)),
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
