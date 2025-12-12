import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers.dart'; // Sesuaikan path
import 'detail_screen.dart';
import 'add_item_screen.dart'; // Jika ada FAB di dalam screen ini

class MyTaskScreen extends StatefulWidget {
  const MyTaskScreen({super.key});

  @override
  State<MyTaskScreen> createState() => _MyTaskScreenState();
}

class _MyTaskScreenState extends State<MyTaskScreen> {
  // Colors Palette
  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGrey = const Color(0xFF9CA3AF);
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color successGreen = const Color(0xFF10B981);
  final Color errorRed = const Color(0xFFEF4444);
  final Color warningOrange = const Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    // Fetch data ulang saat masuk tab ini untuk memastikan data terbaru
    Future.microtask(() => 
      Provider.of<BarangProvider>(context, listen: false).fetchBarang(refresh: true)
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil user saat ini untuk filter
    final currentUser = Provider.of<AuthProvider>(context).currentUser;
    
    return Scaffold(
      backgroundColor: bgPage,
      // AppBar custom agar konsisten dengan desain Home
      appBar: AppBar(
        backgroundColor: bgPage,
        elevation: 0,
        automaticallyImplyLeading: false, // Matikan back button default
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.inventory_2_rounded, color: darkNavy, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("My Tasks", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark)),
                  Text("Your reported items", style: TextStyle(fontSize: 12, color: textGrey, fontWeight: FontWeight.w500)),
                ],
              )
            ],
          ),
        ),
        actions: [
          // Tombol Notifikasi (Opsional jika ingin ada di setiap tab)
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: textDark, size: 28),
            onPressed: () {
               // Logic buka notifikasi / modal
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      
      body: Consumer<BarangProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.listBarang.isEmpty) {
            return Center(child: CircularProgressIndicator(color: darkNavy));
          }

          // Filter Manual: Hanya barang milik user yang login
          // (Idealnya backend punya endpoint /my-items, tapi kita filter client side dulu)
          final myItems = provider.listBarang.where((item) {
             return item.pelapor?.id == currentUser?.id;
          }).toList();

          if (myItems.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchBarang(refresh: true),
            color: darkNavy,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount: myItems.length,
              itemBuilder: (context, index) {
                return _buildTaskItem(myItems[index]);
              },
            ),
          );
        },
      ),
      
      // Floating Action Button khusus untuk halaman ini (Opsional, karena di Home sudah ada)
      // Jika di HomeScreen sudah ada logic FAB, ini bisa dihapus.
      // Namun untuk independensi, saya biarkan.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemScreen()));
        },
        backgroundColor: darkNavy,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.assignment_outlined, size: 60, color: Colors.grey[300]),
          ),
          const SizedBox(height: 20),
          Text("You don't have any tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
          const SizedBox(height: 8),
          Text("Start by reporting a lost or found item.", style: TextStyle(color: textGrey)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Barang item) {
    bool isLost = item.tipeLaporan == 'hilang';
    Color statusColor = isLost ? warningOrange : successGreen;
    String statusText = isLost ? "LOST" : "FOUND";

    // Cek Status Proses
    Color badgeColor = Colors.grey;
    if(item.status == 'open') badgeColor = successGreen;
    if(item.status == 'proses_klaim') badgeColor = warningOrange;
    if(item.status == 'selesai') badgeColor = darkNavy;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(item: item)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))
          ]
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left Side Indicator Strip
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: isLost ? errorRed : successGreen,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                ),
              ),
              
              // Image Thumbnail
              Container(
                width: 80,
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  color: bgPage,
                  borderRadius: BorderRadius.circular(16),
                  image: item.gambarUrl != null 
                      ? DecorationImage(image: NetworkImage(item.gambarUrl!), fit: BoxFit.cover)
                      : null
                ),
                child: item.gambarUrl == null 
                    ? Icon(isLost ? Icons.search_off : Icons.inventory_2, color: Colors.grey[400]) 
                    : null,
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Status Badges Row
                      Row(
                        children: [
                          _buildMiniBadge(statusText, isLost ? errorRed : successGreen),
                          const SizedBox(width: 8),
                          _buildMiniBadge(item.status.toUpperCase().replaceAll('_', ' '), badgeColor, isOutline: true),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        item.namaBarang,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 6),
                      
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: textGrey),
                          const SizedBox(width: 4),
                          Text(
                            item.tanggalKejadian != null 
                              ? DateFormat('dd MMM yyyy').format(item.tanggalKejadian!) 
                              : "-",
                            style: TextStyle(fontSize: 12, color: textGrey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.location_on_rounded, size: 12, color: textGrey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.lokasi?.namaLokasi ?? "-",
                                    style: TextStyle(fontSize: 12, color: textGrey),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),

              // Arrow Right
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color, {bool isOutline = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isOutline ? color : Colors.transparent),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10, 
          fontWeight: FontWeight.bold, 
          color: color
        ),
      ),
    );
  }
}