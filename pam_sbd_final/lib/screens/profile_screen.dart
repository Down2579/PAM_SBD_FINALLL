import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart'; // Pastikan file ini ada
// import 'notification_screen.dart'; // Uncomment jika sudah ada

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ================= COLORS PALETTE =================
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color darkNavy = const Color(0xFF2B4263);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGrey = const Color(0xFF9CA3AF);
  final Color errorRed = const Color(0xFFEF4444);
  final Color accentBlue = const Color(0xFF4A90E2);

  @override
  Widget build(BuildContext context) {
    // Ambil data user dari Provider
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: bgPage,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.person_rounded, color: darkNavy, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("My Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark)),
                  Text("Manage your account", style: TextStyle(fontSize: 12, color: textGrey, fontWeight: FontWeight.w500)),
                ],
              )
            ],
          ),
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. PROFILE HEADER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: darkNavy.withOpacity(0.1),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]
                    ),
                    child: Center(
                      child: Text(
                        user?.namaLengkap.isNotEmpty == true ? user!.namaLengkap[0].toUpperCase() : "U",
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: darkNavy),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name & Role
                  Text(
                    user?.namaLengkap ?? "Loading...",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                      (user?.role ?? "User").toUpperCase(),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: accentBlue),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // User Info Details (Grid)
                  _buildDetailRow(Icons.email_outlined, "Email", user?.email ?? "-"),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.badge_outlined, "NIM", user?.nim ?? "-"),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.phone_outlined, "Phone", user?.nomorTelepon ?? "-"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. MENU OPTIONS
            _buildMenuButton(
              icon: Icons.edit_outlined,
              title: "Edit Profile",
              onTap: () async {
                // Navigasi ke Edit Profile (Perlu dibuat terpisah jika belum ada)
                // Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Edit Profile belum tersedia")));
              }
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              icon: Icons.notifications_none_rounded,
              title: "Notifications",
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
              }
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              icon: Icons.lock_outline_rounded,
              title: "Change Password",
              onTap: () {}
            ),

            const SizedBox(height: 40),

            // 3. LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text(
                  "Sign Out",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            Text("App Version 1.0.0", style: TextStyle(color: textGrey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ================= WIDGETS HELPER =================

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bgPage, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: textGrey),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: textGrey)),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton({required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Icon(icon, color: darkNavy),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title, 
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textDark)
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: textGrey),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Tampilkan Dialog Konfirmasi
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Sign Out", style: TextStyle(color: errorRed, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    ) ?? false;

    if (confirm && context.mounted) {
      // Clear Session
      await Provider.of<AuthProvider>(context, listen: false).logout();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()), // Pastikan LoginScreen ada
          (route) => false,
        );
      }
    }
  }
}