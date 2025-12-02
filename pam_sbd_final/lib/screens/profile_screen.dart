import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'help_center_screen.dart';
import 'profile_detail_screen.dart'; // Pastikan file ini ada
// Import lain yang tidak digunakan dihapus

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color darkBlue = const Color(0xFF2B4263);
  final Color textDark = const Color(0xFF1F1F1F);
  final Color bgGrey = const Color(0xFFF5F5F5);

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
    // TIDAK ADA SCAFFOLD/MATERIAL. LANGSUNG KEMBALIKAN KONTEN.
    // Gunakan ListView agar bisa di-scroll
    return ListView(
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
              Icon(Icons.person_outline_rounded, size: 100, color: textDark),
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
              const SizedBox(height: 40),
              
              // Menu Items
              _buildMenuItem(
                icon: Icons.person_outline,
                title: "Profile",
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileDetailScreen()));
                  _loadUserData(); // Muat ulang data jika ada perubahan
                },
              ),
              // Menurut desain Figma, menu "My Task" tidak ada di sini
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: "Notification",
                onTap: () {
                  // Seharusnya ini mengarah ke Help Center sesuai AppBar
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HelpCenterScreen()));
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
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.white, size: 20),
                      SizedBox(width: 10),
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  // AppBar Kustom
  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48), // Spacer untuk menengahkan judul
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpCenterScreen()),
              );
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
    // Bungkus dengan Padding untuk memberi jarak antar item
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        color: bgGrey,
        borderRadius: BorderRadius.circular(16), // Sesuaikan dengan desain
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: darkBlue, size: 24),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: textDark, size: 16),
              ],
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
            style: ElevatedButton.styleFrom(backgroundColor: darkBlue),
            child: const Text("Sign Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}