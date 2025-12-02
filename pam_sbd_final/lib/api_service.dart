import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class ApiService {
  // =======================================================================
  // KONFIGURASI URL
  // =======================================================================
  // Android Emulator: "http://10.0.2.2:8000/api"
  // HP Fisik / iOS: Ganti dengan IP Laptop, misal "http://192.168.1.10:8000/api"
  static const String baseUrl = "http://10.0.2.2:8000/api";

  // Helper: Ambil Header + Token Otomatis
  Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ===============================================================
  // AUTHENTICATION
  // ===============================================================

  // LOGIN
  Future<User> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    print("POST Login: $url"); // Debug

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    print("Login Status: ${response.statusCode}"); // Debug

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data['user'], data['token']);
    } else {
      final msg = json.decode(response.body)['message'] ?? "Login gagal";
      throw Exception(msg);
    }
  }

  // REGISTER
  Future<bool> register(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/register');
    print("POST Register: $url");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: json.encode(data),
    );
    
    print("Register Status: ${response.statusCode}");
    return response.statusCode == 201 || response.statusCode == 200;
  }

  // UPDATE PROFILE
  Future<bool> updateProfile(int userId, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/users/$userId');
    
    print("PUT Update Profile: $url");

    final response = await http.put(
      url, 
      headers: headers,
      body: json.encode(data),
    );

    print("Update Status: ${response.statusCode}");
    return response.statusCode == 200;
  }

  // ===============================================================
  //  BARANG / ITEMS
  // ===============================================================

  /// Ambil semua barang
  Future<List<Item>> getAllItems() async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/barang');
    print("GET All Items: $url");

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Safety check: Pastikan key 'data' ada dan berupa list
      if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
        final List data = jsonResponse['data'];
        return data.map((e) => Item.fromJson(e)).toList();
      }
      return []; // Return kosong jika data null
    } else {
      print("Error Get All Items: ${response.body}");
      throw Exception("Gagal memuat data barang");
    }
  }

  /// Ambil barang berdasarkan tipe
  Future<List<Item>> getItemsByType(String type) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/barang?tipe_laporan=$type');
    print("GET Items By Type ($type): $url");

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
        final List data = jsonResponse['data'];
        return data.map((e) => Item.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception("Gagal memuat kategori $type");
    }
  }

  /// Ambil barang milik user (My Task)
  Future<List<Item>> getMyItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Key 'userId' harus sama dengan yang disimpan di AuthProvider
    int? userId = prefs.getInt('userId'); 

    if (userId == null) {
      print("Warning: UserId tidak ditemukan di SharedPreferences");
      return [];
    }

    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/barang?user_id=$userId');
    print("GET My Items (User ID: $userId): $url");

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
        final List data = jsonResponse['data'];
        return data.map((e) => Item.fromJson(e)).toList();
      }
      return [];
    } else {
      print("Error Get My Items: ${response.body}");
      return []; // Jangan throw exception agar UI tidak crash, cukup return kosong
    }
  }

  // CREATE BARANG (UPLOAD GAMBAR)
  Future<bool> createItem({
    required Map<String, String> data,
    File? imageFile,
  }) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/barang');
    print("POST Create Item: $url");
    
    var request = http.MultipartRequest('POST', url);

    // Header Authorization manual karena MultipartRequest tidak pakai _getHeaders langsung
    request.headers.addAll(headers);

    // Masukkan data text
    request.fields.addAll(data);

    // Masukkan gambar jika ada
    if (imageFile != null) {
      print("Uploading image: ${imageFile.path}");
      var pic = await http.MultipartFile.fromPath('gambar', imageFile.path);
      request.files.add(pic);
    }

    var streamed = await request.send();
    var response = await http.Response.fromStream(streamed);
    
    print("Create Item Status: ${response.statusCode}");
    print("Response: ${response.body}");

    return response.statusCode == 201 || response.statusCode == 200;
  }

  // CLAIM BARANG
  Future<String> claimItem(int idBarang, String pesan) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/klaim');

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({
        'id_barang': idBarang,
        'pesan_klaim': pesan,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return "Berhasil mengajukan klaim";
    } else {
      try {
        final errBody = json.decode(response.body);
        return errBody['message'] ?? "Gagal mengajukan klaim";
      } catch (e) {
        return "Gagal mengajukan klaim";
      }
    }
  }
}