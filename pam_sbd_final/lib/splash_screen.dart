import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../providers.dart'; 
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/admin/admin_main_screen.dart'; // 1. Tambahkan Import Admin Screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    startSplashScreen();
  }

  startSplashScreen() async {
    // Timer 3 Detik untuk menampilkan logo
    var duration = const Duration(seconds: 3);
    return Timer(duration, () async {
      // Pastikan widget masih ada di tree sebelum mengakses context
      if (mounted) {
        // Ambil instance AuthProvider
        final auth = Provider.of<AuthProvider>(context, listen: false);

        Widget halamanTujuan;

        // 2. LOGIC PENGECEKAN ROLE SAAT AUTO LOGIN
        if (auth.currentUser != null) {
          // Cek apakah user adalah admin
          if (auth.currentUser!.role == 'admin') {
            halamanTujuan = const AdminMainScreen();
          } else {
            halamanTujuan = const HomeScreen();
          }
        } else {
          // Belum login
          halamanTujuan = const LoginScreen();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => halamanTujuan),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Palet Warna
    final Color darkNavy = const Color(0xFF2B4263);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ================= LAPISAN 1: BACKGROUND ATAS =================
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              'assets/images/splash_background.png', 
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),

          // ================= LAPISAN 2: BACKGROUND BAWAH (DIBALIK) =================
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.flip(
              flipY: true, 
              child: Image.asset(
                'assets/images/splash_background.png',
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

          // ================= LAPISAN 3: LOGO DI TENGAH =================
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/logo.png", 
                  width: 150,
                  height: 150,
                  // Fallback jika gambar logo belum ada
                  errorBuilder: (ctx, err, stack) => Icon(
                    Icons.inventory_2_rounded, 
                    size: 100, 
                    color: darkNavy
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "LOST & FOUND",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800, 
                    color: darkNavy,
                    letterSpacing: 2.0, 
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Kemudahan Mencari Barang Anda",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}