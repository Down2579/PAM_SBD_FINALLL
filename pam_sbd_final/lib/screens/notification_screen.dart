import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'my_task_screen.dart';
import 'completed_screen.dart';
import 'profile_screen.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<String> notifications = [
    "Your account is create !",
    "New lost item, check it now!",
    "Your new post has been created",
  ];

  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);
  final Color bubbleColor = const Color(0xFFE8EEF5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= 1. APP BAR (DIMODIFIKASI) =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        // Tombol kembali (panah)
        leading: BackButton(color: textDark),
        
        // ### MODIFIKASI DI SINI: TULISAN "Notification" DIHAPUS ###
        // title: Text(
        //   "Notification",
        //   style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        // ),

        // Hapus centerTitle karena sudah tidak ada title
        // centerTitle: true, 

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, right: 8.0),
                  child: Icon(Icons.notifications_none_outlined, color: textDark, size: 28),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4.0),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ================= 2. BODY KONTEN UTAMA =================
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          Column(
            children: notifications
                .map((text) => NotificationBubble(text: text))
                .toList(),
          ),
        ],
      ),

      // ================= 3. BOTTOM NAVIGATION BAR =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyTaskScreen()));
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CompletedScreen()));
          } else if (index == 3) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
          }
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

// ================= WIDGET KUSTOM UNTUK BUBBLE NOTIFIKASI =================
class NotificationBubble extends StatelessWidget {
  final String text;

  const NotificationBubble({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
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