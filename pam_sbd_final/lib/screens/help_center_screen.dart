import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notification_provider.dart';
import 'home_screen.dart';
import 'my_task_screen.dart';
import 'completed_screen.dart';
import 'profile_screen.dart';
import '../widgets/notification_modal.dart';

class HelpCenterScreen extends StatefulWidget {
  @override
  _HelpCenterScreenState createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _textController = TextEditingController();

  // --- PALET WARNA ---
  final Color darkNavy = const Color(0xFF1e293b);
  final Color accentBlue = const Color(0xFF3b82f6);
  final Color primaryPurple = const Color(0xFF7c3aed);
  final Color textDark = const Color(0xFF1F2937);
  final Color bubbleColor = const Color(0xFFE8EEF5);

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= 1. APP BAR (DIMODIFIKASI) =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        // Tombol kembali fungsional
        leading: BackButton(color: textDark),
        // Judul sekarang ada di AppBar
        title: Text(
          "Help Center",
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Ikon Notifikasi dengan badge dinamis
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return GestureDetector(
                onTap: () async {
                  notificationProvider.reset();
                  await showNotificationsModal(context);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_none_outlined, color: Colors.black, size: 28),
                    if (notificationProvider.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Center(
                            child: Text(
                              '${notificationProvider.unreadCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 16), // Memberi jarak di kanan
        ],
      ),

      // ================= 2. BODY KONTEN UTAMA =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // ### MODIFIKASI: _buildHeader() DIHAPUS dari sini ###
            // const SizedBox(height: 40),

            Text(
              "How can we help you today?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 20),
            _buildTextInputBubble(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),

      // ================= 3. BOTTOM NAVIGATION BAR =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Task"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: "Completed"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), label: "Profile"),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildTextInputBubble() {
    return ClipPath(
      clipper: BubbleClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
        decoration: BoxDecoration(
          color: bubbleColor,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: TextField(
          controller: _textController,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: "........",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () {
            _textController.clear();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: const Text("Undo", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            final message = _textController.text;
            if (message.isNotEmpty) {
              print("Pesan Terkirim: $message");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Message sent!")),
              );
              _textController.clear();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: darkNavy,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: const Text("Send", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}


// ================= CUSTOM CLIPPER =================
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