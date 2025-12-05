import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';

/// NotificationProvider untuk manage notifikasi real-time dari backend
class NotificationProvider extends ChangeNotifier {
  int _unreadCount = 0;
  List<String> _notifications = [];
  bool _isLoading = false;

  int get unreadCount => _unreadCount;
  List<String> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;

  /// Fetch notifikasi dari backend
  Future<void> fetchNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print("Warning: Token tidak ditemukan");
        _isLoading = false;
        notifyListeners();
        return;
      }

      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final url = Uri.parse('${ApiService.baseUrl}/notifikasi');
      final response = await http.get(url, headers: headers);

      print("Fetch Notifications Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        List dataList = (body['data'] as List?) ?? [];
        
        _notifications.clear();
        int unread = 0;

        for (var item in dataList) {
          String message = item['pesan'] ?? 'Notifikasi';
          _notifications.add(message);
          
          // Count unread (status = 0 atau belum dibaca)
          if (item['is_read'] == 0 || item['is_read'] == false) {
            unread++;
          }
        }

        _unreadCount = unread;
        print("Notifications loaded: ${_notifications.length}, Unread: $_unreadCount");
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error fetching notifications: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) return;

      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final url = Uri.parse('${ApiService.baseUrl}/notifikasi/$notificationId/read');
      final response = await http.patch(url, headers: headers);

      if (response.statusCode == 200) {
        print("Notification marked as read");
        // Fetch ulang untuk update count
        await fetchNotifications();
      }
    } catch (e) {
      print("Error marking as read: $e");
    }
  }

  /// Reset unread count (ketika user buka notification)
  void reset() {
    _unreadCount = 0;
    notifyListeners();
  }

  void addNotification(String text) {
    _notifications.insert(0, text);
    _unreadCount++;
    notifyListeners();
  }

  void setCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }
}