import 'package:flutter/material.dart';
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

  // Palet Warna
  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);
  final Color textSecondary = const Color(0xFF6B7280);
  final Color bgGrey = const Color(0xFFF5F7FA);

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
    String displayDate = item.waktu;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        height: 155,
        decoration: BoxDecoration(
          color: bgGrey, 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              decoration: BoxDecoration(
                color: darkNavy,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(Icons.paste_rounded, color: Colors.white, size: 45),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isLost ? "Lost!!" : "Found!!", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark)),
                        Icon(Icons.more_vert, size: 20, color: Colors.grey),
                      ],
                    ),
                    SizedBox(height: 10),
                    _buildIconText(Icons.inventory_2_outlined, item.namaBarang),
                    SizedBox(height: 6),
                    _buildIconText(Icons.location_on_outlined, item.lokasi ?? "-"),
                    SizedBox(height: 6),
                    _buildIconText(Icons.check_circle_outline, "Not found yet"),
                    SizedBox(height: 6),
                    _buildIconText(Icons.calendar_today_outlined, displayDate),
                  ],
                ),
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
        Icon(icon, size: 16, color: textDark),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}