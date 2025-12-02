import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models.dart';
import 'detail_screen.dart';
import 'add_item_screen.dart';
import 'help_center_screen.dart';

class MyTaskScreen extends StatefulWidget {
  @override
  _MyTaskScreenState createState() => _MyTaskScreenState();
}

class _MyTaskScreenState extends State<MyTaskScreen> {
  final ApiService api = ApiService();

  // Palet Warna
  final Color darkBlue = const Color(0xFF2B4263);
  final Color textDark = const Color(0xFF1F1F1F);
  final Color bgGrey = const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    // ### MODIFIKASI UTAMA DI SINI ###
    // Bungkus semua konten dengan widget Material untuk memberikan "dasar" visual
    return Material(
      color: Colors.white, // Atur warna latar belakang di sini
      child: Stack(
        children: [
          // KONTEN UTAMA HALAMAN
          Column(
            children: [
              // ================= 1. HEADER =================
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
                        Icon(Icons.menu, size: 28, color: textDark),
                        IconButton(
                          icon: Icon(Icons.notifications_none_outlined, size: 28, color: textDark),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HelpCenterScreen()),
                            );
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
                              return Icon(Icons.inventory_2_outlined, size: 48, color: darkBlue);
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("My Task", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textDark)),
                            Text("Found yours !", style: TextStyle(fontSize: 14, color: darkBlue, fontWeight: FontWeight.w600)),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // ================= 2. CONTENT LIST =================
              Expanded(
                child: FutureBuilder<List<Item>>(
                  future: api.getMyItems(), 
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: darkBlue));
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

          // ================= FAB (TOMBOL TAMBAH) =================
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
              backgroundColor: darkBlue,
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

  // ================= WIDGET ITEM (DESIGN KARTU) - Tidak Berubah =================
  Widget _buildTaskItem(Item item) {
    bool isLost = item.tipeLaporan?.toLowerCase() == "hilang";
    String displayDate = item.waktu ?? "11/21/2025"; 

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
                color: darkBlue,
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