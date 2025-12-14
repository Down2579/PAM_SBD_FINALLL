import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../notification_provider.dart'; 
import '../models.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Ambil data saat halaman dibuka
    Future.microtask(() => 
      Provider.of<NotifikasiProvider>(context, listen: false).fetchNotifikasi()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Notifikasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2B4263),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
               Provider.of<NotifikasiProvider>(context, listen: false).clearAll();
            },
            tooltip: "Bersihkan Semua",
          )
        ],
      ),
      body: Consumer<NotifikasiProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.listNotif.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Tidak ada notifikasi", style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.listNotif.length,
            itemBuilder: (context, index) {
              final notif = provider.listNotif[index];
              return _buildNotifItem(notif, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotifItem(Notifikasi notif, NotifikasiProvider provider) {
    // Style beda jika belum dibaca
    final bool isUnread = !notif.sudahDibaca;
    final Color bgColor = isUnread ? Colors.blue.withOpacity(0.05) : Colors.white;
    final FontWeight fontWeight = isUnread ? FontWeight.bold : FontWeight.normal;

    return Container(
      margin: const EdgeInsets.only(bottom: 1), // Garis pemisah tipis
      color: bgColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          provider.markAsRead(notif.id);
          // Disini bisa tambah navigasi ke DetailScreen jika perlu
        },
        leading: CircleAvatar(
          backgroundColor: isUnread ? Colors.blue : Colors.grey[300],
          child: Icon(
            Icons.notifications, 
            color: isUnread ? Colors.white : Colors.grey[600]
          ),
        ),
        title: Text(
          notif.judul,
          style: TextStyle(fontWeight: fontWeight, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notif.pesan, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 6),
            Text(
              DateFormat('dd MMM yyyy, HH:mm').format(notif.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: isUnread 
            ? const Icon(Icons.circle, size: 10, color: Colors.blue) 
            : null,
      ),
    );
  }
}