import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers.dart'; // Pastikan path ke file providers.dart benar
import 'splash_screen.dart'; 
import 'notification_provider.dart'; // Pastikan path ke splash screen benar

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. AuthProvider (Login/Register/Sesi)
        // Menggunakan tryAutoLogin() bukan checkSession()
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..tryAutoLogin(),
        ),

        // 2. BarangProvider (CRUD Barang)
        ChangeNotifierProvider(
          create: (_) => BarangProvider(),
        ),

        // 3. KlaimProvider (Transaksi Klaim)
        ChangeNotifierProvider(
          create: (_) => KlaimProvider(),
        ),

        // 4. GeneralProvider (Kategori, Lokasi, Notifikasi)
        ChangeNotifierProvider(
          create: (_) => GeneralProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotifikasiProvider()),
      ],
      child: MaterialApp(
        title: 'LostFound',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Warna background konsisten
          fontFamily: 'Poppins', // Opsional jika Anda punya font
        ),
        home: const SplashScreen(),
      ),
    );
  }
}