import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers.dart';
// import 'screens/login_screen.dart'; // Tidak perlu di-import di sini lagi
// import 'screens/home_screen.dart';  // Tidak perlu di-import di sini lagi
import 'splash_screen.dart'; // WAJIB: Import file splash screen yang baru dibuat

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // checkSession() tetap berjalan di background agar datanya siap
        // saat timer Splash Screen selesai.
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkSession()),
      ],
      child: MaterialApp(
        title: 'LostFound',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        // PERUBAHAN UTAMA DI SINI:
        // Kita tidak lagi menggunakan Consumer langsung di sini.
        // Kita panggil SplashScreen() sebagai halaman pertama.
        home: const SplashScreen(),
      ),
    );
  }
}