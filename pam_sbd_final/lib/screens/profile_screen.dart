import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ================= COLORS =================
  final Color bgPage = const Color(0xFFF1F3F7);
  final Color darkNavy = const Color(0xFF2B4263);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGrey = const Color(0xFF9CA3AF);
  final Color errorRed = const Color(0xFFEF4444);
  final Color accentBlue = const Color(0xFF4A90E2);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: bgPage,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: bgPage,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(Icons.person_rounded,
                    color: darkNavy, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("My Profile",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textDark)),
                  Text("Manage your account",
                      style: TextStyle(
                          fontSize: 12,
                          color: textGrey,
                          fontWeight: FontWeight.w500)),
                ],
              )
            ],
          ),
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ================= PROFILE CARD =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black.withOpacity(0.04)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    blurRadius: 1,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ================= AVATAR =================
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          darkNavy.withOpacity(0.9),
                          darkNavy.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: darkNavy.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user?.namaLengkap.isNotEmpty == true
                            ? user!.namaLengkap[0].toUpperCase()
                            : "U",
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    user?.namaLengkap ?? "Loading...",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textDark),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  _roleBadge(user?.role ?? "User"),

                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 24),

                  _buildDetailRow(
                      Icons.email_outlined, "Email", user?.email ?? "-"),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                      Icons.badge_outlined, "NIM", user?.nim ?? "-"),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.phone_outlined, "Phone",
                      user?.nomorTelepon ?? "-"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= MENU =================
            _menuCard(
              icon: Icons.edit_outlined,
              title: "Edit Profile",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Fitur Edit Profile belum tersedia")),
                );
              },
            ),
            const SizedBox(height: 12),
            _menuCard(
              icon: Icons.notifications_none_rounded,
              title: "Notifications",
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _menuCard(
              icon: Icons.lock_outline_rounded,
              title: "Change Password",
              onTap: () {},
            ),

            const SizedBox(height: 40),

            // ================= LOGOUT =================
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.white),
                label: const Text(
                  "Sign Out",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text("Lost & Found IT DEL",
                style: TextStyle(color: textGrey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ================= COMPONENTS =================

  Widget _roleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: accentBlue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: accentBlue,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgPage,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: textGrey),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12, color: textGrey)),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _menuCard(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: darkNavy),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textDark)),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: textGrey),
          ],
        ),
      ),
    );
  }

  // ================= LOGOUT =================
  Future<void> _handleLogout(BuildContext context) async {
    bool confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Sign Out"),
            content:
                const Text("Are you sure you want to sign out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel",
                    style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text("Sign Out",
                    style: TextStyle(
                        color: errorRed,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm && context.mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
