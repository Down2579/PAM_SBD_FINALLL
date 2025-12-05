import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'notification_screen.dart';
import 'profile_detail_screen.dart';
import 'edit_profile_screen.dart';
import 'help_center_screen.dart';
import '../widgets/notification_modal.dart';
import 'home_screen.dart';
import 'my_task_screen.dart';
import 'completed_screen.dart';
// Import lain yang tidak digunakan dihapus

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);
  final Color bgGrey = const Color(0xFFF5F7FA);
  final Color textSecondary = const Color(0xFF6B7280);
  final Color errorRed = const Color(0xFFEF4444);

  String _fullName = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) { // Pastikan widget masih ada di tree
      setState(() {
        _fullName = prefs.getString('username') ?? "User Name";
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Pastikan context valid sebelum navigasi
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero, // Hapus padding default ListView
        children: [
          // Padding atas untuk menggantikan SafeArea
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: _buildCustomAppBar(context),
          ),

          // Sisa konten dibungkus Padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [darkNavy, darkNavy.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: darkNavy.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Icon(Icons.person_outline_rounded, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  _fullName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Manage your account",
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 40),

                // Menu Items
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: "Profile",
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    );
                    if (result == true) {
                      _loadUserData(); // Reload jika ada perubahan
                    }
                  },
                ),
                // Menurut desain Figma, menu "My Task" tidak ada di sini
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: "Notification",
                  onTap: () {
                    // Navigasi ke halaman notifikasi
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => NotificationScreen()));
                  },
                ),
                _buildMenuItem(
                  icon: Icons.lock_outline,
                  title: "Change Password",
                  onTap: () {
                    // Arahkan ke halaman ganti password jika ada
                    print("Navigasi ke Change Password");
                  },
                ),
                const SizedBox(height: 50),

                // Tombol Sign Out
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        errorRed,
                        errorRed.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: errorRed.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _showLogoutDialog(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            "Sign Out",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // AppBar Kustom
  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: textDark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpCenterScreen()),
              );
            },
          ),
          Text(
            "Profile",
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications_none_outlined, color: textDark),
            onPressed: () async {
              await showNotificationsModal(context);
            },
          ),
        ],
      ),
    );
  }

  // Widget untuk setiap item menu
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    const Color borderGrey = Color(0xFFE5E7EB);
    const Color menuTextSecondary = Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderGrey, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [darkNavy, darkNavy.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textDark,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Tap to manage",
                          style: TextStyle(
                            fontSize: 12,
                            color: menuTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: menuTextSecondary, size: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Dialog konfirmasi logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog dulu
              _handleLogout(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: darkNavy),
            child: const Text("Sign Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}