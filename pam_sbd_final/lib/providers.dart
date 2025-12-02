import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  final ApiService _api = ApiService();

  User? get user => _user;
  bool get isLoading => _isLoading; 

  // ==================== LOGIN ====================
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Request ke API
      _user = await _api.login(email, password);

      // 2. Jika login sukses & data user ada, simpan ke memori HP
      if (_user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // A. Simpan Token & ID (Penting untuk API calls berikutnya)
        if (_user!.token != null) {
          await prefs.setString('token', _user!.token!);
        }
        await prefs.setInt('userId', _user!.id);

        // B. Simpan Data Profil 
        // PENTING: Key menggunakan huruf kecil agar sesuai dengan HomeScreen & ProfileScreen
        await prefs.setString('username', _user!.namaLengkap); 
        await prefs.setString('nim', _user!.nim);
        await prefs.setString('email', _user!.email); 
        await prefs.setString('hp', _user!.nomorTelepon ?? "-"); 
        
        print("DEBUG: Data user disimpan. Nama: ${_user!.namaLengkap}");
      }

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      print("Login Error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== REGISTER ====================
  Future<bool> register(String nama, String nim, String email, String hp, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _api.register({
        'nama_lengkap': nama,
        'nim': nim,
        'email': email,
        'nomor_telepon': hp,
        'password': password,
        'role': 'mahasiswa',
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Register Error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== UPDATE PROFILE ====================
  Future<bool> updateProfile(String nama, String hp, String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_user == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 1. Panggil API Update
      bool success = await _api.updateProfile(_user!.id, {
        'nama_lengkap': nama,
        'nomor_telepon': hp,
        'email': email,
      });

      // 2. Jika sukses, update data Lokal agar UI langsung berubah
      if (success) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // Update Memori HP (Key huruf kecil)
        await prefs.setString('username', nama);
        await prefs.setString('hp', hp);
        await prefs.setString('email', email);

        // Update Object User di State Aplikasi
        _user = User(
          id: _user!.id,
          namaLengkap: nama,
          nim: _user!.nim, // NIM biasanya tidak berubah
          email: email,
          nomorTelepon: hp,
          role: _user!.role,
          token: _user!.token
        );
      }

      _isLoading = false;
      notifyListeners();
      return success;

    } catch (e) {
      print("Update Profile Error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus SEMUA data sesi (Token, Nama, dll)
    _user = null;
    notifyListeners();
  }

  // ==================== CEK SESI (AUTO LOGIN) ====================
  // Dipanggil di main.dart atau splash screen
  Future<void> checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    // Jika ada token tersimpan, kembalikan user ke state login
    if (token != null && token.isNotEmpty) {
      // Ambil data profil yang tersimpan di HP
      int savedId = prefs.getInt('userId') ?? 0;
      String savedName = prefs.getString('username') ?? "User";
      String savedNim = prefs.getString('nim') ?? "-";
      String savedEmail = prefs.getString('email') ?? "-";
      String savedPhone = prefs.getString('hp') ?? "-";

      // Rekonstruksi Object User
      _user = User(
        id: savedId,
        namaLengkap: savedName,
        nim: savedNim,
        email: savedEmail,
        nomorTelepon: savedPhone,
        role: "mahasiswa", 
        token: token
      );
      
      notifyListeners();
    }
  }
}