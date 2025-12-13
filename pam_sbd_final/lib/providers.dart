import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'models.dart';

// ============================================================================
// 1. AUTH PROVIDER (Login, Register, Session)
// ============================================================================
class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  /// Cek sesi login saat aplikasi dibuka (Auto Login)
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user') || !prefs.containsKey('token')) {
      return false;
    }
    try {
      final userData = jsonDecode(prefs.getString('user') ?? '{}');
      _currentUser = User.fromJson(userData);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String emailOrNim, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.login(emailOrNim, password);
      _currentUser = User.fromJson(data['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.register(data);
      _currentUser = User.fromJson(res['user']);
      
      // Simpan sesi otomatis setelah register
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', res['token']);
      await prefs.setString('user', jsonEncode(res['user']));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore logout errors
    }
    _currentUser = null;
    notifyListeners();
  }
}

// ============================================================================
// 2. BARANG PROVIDER (CRUD Barang)
// ============================================================================
class BarangProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Barang> _listBarang = [];
  Barang? _selectedBarang;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Pagination (Opsional jika backend mendukung)
  int _currentPage = 1;
  bool _hasMore = true;

  List<Barang> get listBarang => _listBarang;
  Barang? get selectedBarang => _selectedBarang;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBarang({
    bool refresh = false, 
    String? type, 
    String? status, 
    String? search
  }) async {
    if (refresh) {
      _currentPage = 1;
      _listBarang = [];
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    if (refresh) notifyListeners(); 

    try {
      final response = await _apiService.getBarang(
        page: _currentPage,
        type: type,
        status: status,
        search: search
      );

      final List<dynamic> data = response['data'];
      final Map<String, dynamic>? meta = response['meta'];

      List<Barang> newItems = data.map((e) => Barang.fromJson(e)).toList();

      if (refresh) {
        _listBarang = newItems;
      } else {
        _listBarang.addAll(newItems);
      }

      // Handle Pagination
      if (meta != null) {
        if (_currentPage >= (meta['last_page'] ?? 1)) {
          _hasMore = false;
        } else {
          _currentPage++;
        }
      } else {
        if (newItems.isEmpty) _hasMore = false;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> getDetail(int id) async {
    _isLoading = true;
    _selectedBarang = null; // Reset agar UI menampilkan loading
    notifyListeners();
    
    try {
      final data = await _apiService.getDetailBarang(id);
      _selectedBarang = Barang.fromJson(data);
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addBarang(Map<String, String> fields, File? image, List<File>? others) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _apiService.createBarang(fields, image, others);
      await fetchBarang(refresh: true); // Refresh list setelah upload sukses
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

// ============================================================================
// 3. KLAIM PROVIDER (User & Admin Actions)
// ============================================================================
class KlaimProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<KlaimPenemuan> _klaimList = [];
  bool _isLoading = false;

  List<KlaimPenemuan> get klaimList => _klaimList;
  bool get isLoading => _isLoading;

  /// Load klaim spesifik untuk barang tertentu (Detail Page)
  Future<void> loadKlaimByBarang(int idBarang) async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> data = await _apiService.getKlaimByBarang(idBarang);
      _klaimList = data.map((e) => KlaimPenemuan.fromJson(e)).toList();
    } catch (e) {
      _klaimList = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  /// [ADMIN] Load semua klaim yang masuk
  Future<void> fetchAllKlaim() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> data = await _apiService.getAllKlaim();
      _klaimList = data.map((e) => KlaimPenemuan.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching all klaim: $e");
      _klaimList = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  /// User mengajukan klaim baru
  Future<bool> ajukanKlaim(Map<String, String> fields, File? foto) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.createKlaim(fields, foto);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update status klaim (Terima/Tolak oleh Admin/Pemilik)
  Future<bool> updateStatus(int klaimId, String status) async {
    try {
      bool success = await _apiService.updateStatusKlaim(klaimId, status);
      if (success) {
        // Refresh list agar status terbaru muncul
        await fetchAllKlaim();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Upload bukti penyerahan barang (Finalisasi)
  Future<bool> uploadBukti(int idBarang, File foto, String catatan) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.uploadBukti(idBarang, foto, catatan);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

// ============================================================================
// 4. GENERAL PROVIDER (Master Data: Kategori, Lokasi, Notifikasi)
// ============================================================================
class GeneralProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Kategori> _kategoriList = [];
  bool _isLoading = false;
  List<Lokasi> _lokasiList = [];
  List<Notifikasi> _notifList = [];

  List<Kategori> get kategoriList => _kategoriList;
  bool get isLoading => _isLoading;
  List<Lokasi> get lokasiList => _lokasiList;
  List<Notifikasi> get notifList => _notifList;

  Future<void> loadMasterData() async {
    try {
      final List<dynamic> k = await _apiService.getKategori();
      final List<dynamic> l = await _apiService.getLokasi();
      
      _kategoriList = k.map((e) => Kategori.fromJson(e)).toList();
      _lokasiList = l.map((e) => Lokasi.fromJson(e)).toList();
      
      notifyListeners();
    } catch (e) {
      print("Error loading master data: $e");
    }
  }

  // --- CRUD KATEGORI ---
  Future<void> fetchKategori() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> data = await _apiService.getKategori();
      _kategoriList = data.map((json) => Kategori.fromJson(json)).toList();
    } catch (e) {
      print("Error loading kategori: $e");
      _kategoriList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addKategori(String nama, String deskripsi) async {
    try {
      final newItem = await _apiService.createKategori(nama, deskripsi);
      _kategoriList.add(Kategori.fromJson(newItem));
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> editKategori(int id, String namaBaru, String deskripsi) async {
    try {
      bool success = await _apiService.updateKategori(id, namaBaru, deskripsi);
      if (success) {
        final index = _kategoriList.indexWhere((item) => item.id == id);
        if (index != -1) {
          _kategoriList[index] = Kategori(
            id: id, 
            namaKategori: namaBaru, 
            deskripsi: _kategoriList[index].deskripsi
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteKategori(int id) async {
    try {
      bool success = await _apiService.deleteKategori(id);
      if (success) {
        _kategoriList.removeWhere((item) => item.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // --- CRUD LOKASI ---

  Future<bool> addLokasi(String nama, String deskripsi) async {
    try {
      final newItem = await _apiService.createLokasi(nama, deskripsi);
      _lokasiList.add(Lokasi.fromJson(newItem));
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> editLokasi(int id, String namaBaru, String deskripsi) async {
    try {
      bool success = await _apiService.updateLokasi(id, namaBaru, deskripsi);
      if (success) {
        final index = _lokasiList.indexWhere((item) => item.id == id);
        if (index != -1) {
          _lokasiList[index] = Lokasi(
            id: id, 
            namaLokasi: namaBaru, 
            deskripsi: _lokasiList[index].deskripsi
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteLokasi(int id) async {
    try {
      bool success = await _apiService.deleteLokasi(id);
      if (success) {
        _lokasiList.removeWhere((item) => item.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // --- NOTIFIKASI ---

  Future<void> loadNotifikasi() async {
    try {
      final List<dynamic> n = await _apiService.getNotifikasi();
      _notifList = n.map((e) => Notifikasi.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      print("Error loading notif: $e");
    }
  }
}