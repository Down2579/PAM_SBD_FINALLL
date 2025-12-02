import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'my_task_screen.dart';
import 'completed_screen.dart';
import 'profile_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  @override
  _HelpCenterScreenState createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  // Controller untuk mengambil teks dari TextField
  final TextEditingController _textController = TextEditingController();

  // --- PALET WARNA ---
  final Color darkBlue = const Color(0xFF2B4263);
  final Color textDark = const Color(0xFF1F1F1F);
  final Color bubbleColor = const Color(0xFFE8E8E8);

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= 1. APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        title: Text(
          "Help Center",
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        leading: Icon(
          Icons.menu,
          color: textDark,
          size: 28,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(
                  Icons.notifications_none_outlined,
                  color: textDark,
                  size: 30,
                ),
                Container(
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ================= 2. BODY KONTEN UTAMA =================
      body: SingleChildScrollView( // Agar tidak overflow saat keyboard muncul
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- Header Judul ---
            _buildHeader(),
            const SizedBox(height: 40),

            // --- Judul Form ---
            Text(
              "How can we help you today?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 20),

            // --- Text Input Bubble ---
            _buildTextInputBubble(),
            const SizedBox(height: 20),

            // --- Tombol Aksi ---
            _buildActionButtons(),
          ],
        ),
      ),

      // ================= 3. BOTTOM NAVIGATION BAR =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Asumsikan kembali ke home
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
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
        selectedItemColor: darkBlue,
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
            'assets/images/logo.png', // Pastikan path logo benar
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.inventory_2_outlined, size: 48, color: darkBlue);
            },
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Help Center",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Something looking for you",
              style: TextStyle(
                color: darkBlue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
      ],
    );
  }

  // --- WIDGET HELPER: Text Input Bubble ---
  Widget _buildTextInputBubble() {
    return ClipPath(
      clipper: BubbleClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 25), // Padding disesuaikan
        decoration: BoxDecoration(
          color: bubbleColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _textController,
          maxLines: 5, // Atur jumlah baris
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: "........",
            border: InputBorder.none, // Hapus garis bawah
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: Tombol Aksi ---
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Tombol Undo
        ElevatedButton(
          onPressed: () {
            _textController.clear(); // Bersihkan teks
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: Text("Undo", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 10),
        // Tombol Send
        ElevatedButton(
          onPressed: () {
            // Tambahkan logika untuk mengirim pesan di sini
            final message = _textController.text;
            print("Pesan Terkirim: $message");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Message sent!")),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: darkBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: Text("Send", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}


// ================= CLIPPER KUSTOM UNTUK BENTUK BUBBLE =================
// (Sama seperti yang digunakan di notification_screen.dart)
class BubbleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = 20.0;
    final tailSize = 15.0;

    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius));
    path.lineTo(size.width, size.height - radius - tailSize);
    path.arcToPoint(Offset(size.width - radius, size.height - tailSize), radius: Radius.circular(radius));
    path.lineTo(size.width - radius * 1.5, size.height - tailSize);
    path.lineTo(size.width - radius - tailSize, size.height);
    path.lineTo(size.width - radius - tailSize, size.height - tailSize);
    path.lineTo(radius, size.height - tailSize);
    path.arcToPoint(Offset(0, size.height - radius - tailSize), radius: Radius.circular(radius));
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius));

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}