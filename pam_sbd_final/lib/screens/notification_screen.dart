import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // DITAMBAHKAN
import '../notification_provider.dart'; // DITAMBAHKAN
import 'home_screen.dart';
import 'my_task_screen.dart';
import 'completed_screen.dart';
import 'profile_screen.dart';
import 'help_center_screen.dart'; // Ditambahkan untuk navigasi dari ikon lonceng

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // --- Data Dummy ---
  final List<String> notifications = [
    "Your account is create !",
    "New lost item, check it now!",
    "Your new post has been created",
  ];

  // --- Palet Warna ---
  final Color darkNavy = const Color(0xFF1e293b);
  final Color accentBlue = const Color(0xFF3b82f6);
  final Color primaryPurple = const Color(0xFF7c3aed);
  final Color textDark = const Color(0xFF1F2937);
  final Color bubbleColor = const Color(0xFFE8EEF5); // Warna bubble/kartu notifikasi

  @override
  void initState() {
    super.initState();
    // ### MODIFIKASI: Reset notifikasi saat halaman dibuka ###
    // Menggunakan addPostFrameCallback agar reset terjadi setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= 1. APP BAR (DIMODIFIKASI) =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        // Tombol kembali otomatis
        leading: BackButton(color: textDark),
        // Tidak ada judul (title)
        actions: [
          // ### MODIFIKASI: Ikon notif di sini juga menggunakan Consumer ###
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_none_outlined, color: textDark, size: 28),
                    onPressed: () {
                      // Jika pengguna ada di halaman Help Center (notif), tidak perlu navigasi lagi
                      // Atau bisa diarahkan ke halaman lain jika perlu
                    },
                  ),
                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5)
                        ),
                        constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Center(
                          child: Text(
                            '${notificationProvider.unreadCount}',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8), // Memberi sedikit jarak di kanan
        ],
      ),

      // ================= 2. BODY KONTEN UTAMA =================
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          Column(
            children: notifications.map((text) => NotificationBubble(text: text)).toList(),
          ),
        ],
      ),

      // ================= 3. BOTTOM NAVIGATION BAR =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Default ke Home saat di halaman ini
        onTap: (index) {
          if (index == 0) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);
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

  // --- WIDGET HELPER: Header Judul ---
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Notification",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 4),
            Text(
              "Something looking for you",
              style: TextStyle(color: darkNavy, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        )
      ],
    );
  }
}

// ================= WIDGET KUSTOM UNTUK BUBBLE (DIMODIFIKASI) =================
class NotificationBubble extends StatelessWidget {
  final String text;

  const NotificationBubble({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ### MODIFIKASI: Menggunakan Container biasa, bukan ClipPath ###
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(16), // Menggunakan border radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F1F1F),
        ),
      ),
    );
  }
}