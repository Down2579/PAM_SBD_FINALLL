import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models.dart';

class NotifikasiProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Notifikasi> _listNotif = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<Notifikasi> get listNotif => _listNotif;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifikasi() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.getNotifikasi();
      // Backend return: {'data': [...], 'unread_count': 5}
      
      if (res['data'] != null) {
        final List<dynamic> data = res['data'];
        _listNotif = data.map((json) => Notifikasi.fromJson(json)).toList();
      }
      
      _unreadCount = res['unread_count'] ?? 0;
      
    } catch (e) {
      print("Error Notif: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    // Update UI dulu biar cepat (Optimistic Update)
    int index = _listNotif.indexWhere((n) => n.id == id);
    if (index != -1 && !_listNotif[index].sudahDibaca) {
      _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
      // Kita gak bisa ubah object final, jadi biarkan fetch ulang nanti mengurusnya
      // atau buat object baru jika ingin instant update di list
      notifyListeners();
      
      // Panggil API
      await _apiService.markNotifRead(id);
      // Fetch ulang agar data sinkron
      await fetchNotifikasi();
    }
  }
  
  Future<void> clearAll() async {
    await _apiService.clearAllNotif();
    _listNotif = [];
    _unreadCount = 0;
    notifyListeners();
  }
}