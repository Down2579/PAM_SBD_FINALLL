import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';
import '../models.dart';
import 'detail_screen.dart';
import 'add_item_screen.dart';
import 'notification_screen.dart'; // <--- DIPERBAIKI: Import NotificationScreen
import 'help_center_screen.dart';
import '../widgets/notification_modal.dart';

class MyTaskScreen extends StatefulWidget {
  @override
  _MyTaskScreenState createState() => _MyTaskScreenState();
}

class _MyTaskScreenState extends State<MyTaskScreen> {
  final ApiService api = ApiService();
  late Future<List<Item>> _itemsFuture;

  // Palet Warna
  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);
  final Color textSecondary = const Color(0xFF6B7280);
  final Color bgGrey = const Color(0xFFF5F7FA);
  final Color errorRed = const Color(0xFFEF4444);
  final Color successGreen = const Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _itemsFuture = api.getMyItems();
  }

  Future<void> _refreshItems() async {
    setState(() {
      _itemsFuture = api.getMyItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kode ini menggunakan struktur lama Anda, tanpa BottomNavBar,
    // karena Anda memintanya berdasarkan kode yang Anda berikan.
    return Material(
      color: Colors.white,
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 24,
                  right: 24,
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.menu, size: 28, color: textDark),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HelpCenterScreen()),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.notifications_none_outlined, size: 28, color: textDark),
                          onPressed: () async {
                            await showNotificationsModal(context);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: Image.asset(
                            'assets/images/logo.png',
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.inventory_2_outlined, size: 48, color: darkNavy);
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("My Task", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textDark)),
                            Text("Found yours !", style: TextStyle(fontSize: 14, color: darkNavy, fontWeight: FontWeight.w600)),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Item>>(
                  future: api.getMyItems(), 
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: darkNavy));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text("You don’t have any task", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                      );
                    }
                    List<Item> items = snapshot.data!;
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _buildTaskItem(items[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => AddItemScreen())
                );
                setState(() {}); 
              },
              backgroundColor: darkNavy,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), 
              ),
              child: Icon(Icons.add, size: 35, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Item item) {
    bool isLost = item.tipeLaporan.toLowerCase() == "hilang";
    const Color borderGrey = Color(0xFFE5E7EB);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
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
                  colors: [
                    isLost ? errorRed : successGreen,
                    (isLost ? errorRed : successGreen).withOpacity(0.7),
                  ],
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
                          item.waktu,
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