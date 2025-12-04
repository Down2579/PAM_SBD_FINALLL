import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'providers.dart'; // Import provider kamu
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

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
    // Timer 3 Detik
    var duration = const Duration(seconds: 3);
    return Timer(duration, () {
      // Pastikan widget masih ada di tree sebelum mengakses context
      if (mounted) {
        // Ambil data dari AuthProvider
        final auth = Provider.of<AuthProvider>(context, listen: false);

        // Cek Logika: Kalau user ada (sudah login) ke Home, kalau tidak ke Login
        Widget halamanTujuan = auth.user != null ? HomeScreen() : LoginScreen();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => halamanTujuan),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Palet Warna (konsisten dengan aplikasi Anda)
    final Color darkNavy = const Color(0xFF2B4263);
    final Color accentBlue = const Color(0xFF4A90E2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand, // Membuat Stack memenuhi seluruh layar
        children: [
          // ================= LAPISAN 1: BACKGROUND ATAS =================
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              'assets/images/splash_background.png', // Pastikan file ini ada
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(), // Sembunyikan jika error
            ),
          ),

          // ================= LAPISAN 2: BACKGROUND BAWAH (DIBALIK) =================
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.flip(
              flipY: true, // Membalik gambar secara vertikal
              child: Image.asset(
                'assets/images/splash_background.png', // Pastikan file ini ada
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

          // ================= LAPISAN 3: LOGO DI TENGAH =================
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Membuat Column sekecil mungkin
              children: [
                Image.asset(
                  "assets/images/logo.png", 
                  width: 180,
                  height: 180,
                ),
                const SizedBox(height: 16),
                Text(
                  "LOST & FOUND",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkNavy, // Menggunakan warna yang konsisten
                    letterSpacing: 1.5,
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