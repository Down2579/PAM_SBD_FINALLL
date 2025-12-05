import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers.dart'; // File ini kemungkinan berisi AuthProvider
import 'notification_provider.dart'; // DITAMBAHKAN: Import NotificationProvider
import 'splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. AuthProvider untuk manajemen login & sesi
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkSession()),

        // ### MODIFIKASI UTAMA DI SINI ###
        // 2. NotificationProvider untuk manajemen state notifikasi
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        
        // Anda bisa menambahkan provider lain di sini jika dibutuhkan di masa depan
      ],
      child: MaterialApp(
        title: 'LostFound',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          // Menambahkan ScaffolodBackgroundColor agar konsisten
          scaffoldBackgroundColor: Colors.white, 
        ),
        home: const SplashScreen(),
      ),
    );
  }
}