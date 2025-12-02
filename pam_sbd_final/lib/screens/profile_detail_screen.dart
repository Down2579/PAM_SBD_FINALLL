import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'help_center_screen.dart'; // <--- DITAMBAHKAN: Import halaman Help Center

class ProfileDetailScreen extends StatefulWidget {
  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  // ================= COLORS PALETTE =================
  final Color darkBlue = const Color(0xFF2B4263); // Warna teks biru
  final Color textDark = const Color(0xFF1F1F1F);
  final Color bgGrey = const Color(0xFFF5F5F5);   // Warna background kolom

  // Variable Data
  String _fullName = "...";
  String _nim = "...";
  String _email = "...";
  String _phone = "...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ================= LOAD DATA =================
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('username') ?? "User";
      _nim = prefs.getString('nim') ?? "-";
      _email = prefs.getString('email') ?? "-";
      _phone = prefs.getString('hp') ?? "-";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // ================= 1. HEADER (DIMODIFIKASI) =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, size: 28, color: textDark), // Mengganti ikon agar lebih jelas
                  ),
                  
                  // Tombol Notifikasi diubah menjadi IconButton
                  IconButton(
                    icon: Icon(Icons.notifications_none_outlined, size: 28, color: textDark),
                    onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HelpCenterScreen()),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 30),

              // ================= 2. TITLE & AVATAR =================
              Text(
                "Profile",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              SizedBox(height: 20),

              Icon(
                Icons.person_outline_rounded,
                size: 100,
                color: textDark,
              ),

              SizedBox(height: 10),

              Text(
                _fullName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkBlue, 
                ),
              ),

              SizedBox(height: 40),

              // ================= 3. INFO FIELDS =================
              _buildInfoRow("Name", _fullName),
              _buildInfoRow("NIM", _nim),
              _buildInfoRow("Email", _email),
              _buildInfoRow("Phone", _phone),
              _buildInfoRow("Password", "************"),
            ],
          ),
        ),
      ),
    );
  }

  // ================= WIDGET HELPER =================
  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: bgGrey,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: darkBlue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          
          Text(
            ":  ",
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.bold,
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textDark,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}