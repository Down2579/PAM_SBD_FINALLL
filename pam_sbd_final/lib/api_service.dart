import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart'; 

class ApiService {
  // Ganti IP sesuai device:
  // Android Emulator: 'http://10.0.2.2:8000/api'
  // iOS Simulator / Real Device: 'http://<IP_LAPTOP_ANDA>:8000/api'
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // --- HELPER: GET HEADERS ---
  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    Map<String, String> headers = {
      'Accept': 'application/json',
    };

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ===========================================================================
  // AUTHENTICATION
  // ===========================================================================

  Future<Map<String, dynamic>> login(String emailOrNim, String password) async {
    final url = Uri.parse('$baseUrl/login');
    
    final body = {
      'password': password,
    };
    if (emailOrNim.contains('@')) {
      body['email'] = emailOrNim;
    } else {
      body['nim'] = emailOrNim;
    }

    final response = await http.post(
      url,
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user', jsonEncode(data['user']));
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['message'] ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    final url = Uri.parse('$baseUrl/logout');
    try {
      final headers = await _getHeaders();
      await http.post(url, headers: headers);
    } catch (e) {
      // Ignore error on logout
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ===========================================================================
  // BARANG (Lost & Found Items)
  // ===========================================================================

// Di file api_service.dart

  Future<Map<String, dynamic>> getBarang({
    int page = 1,
    String? type, 
    String? status, 
    String? search,
  }) async {
    String query = '?page=$page';
    if (type != null) query += '&tipe=$type';
    if (status != null) query += '&status=$status';
    if (search != null && search.isNotEmpty) query += '&q=$search';

    final url = Uri.parse('$baseUrl/barang$query');
    final headers = await _getHeaders();
    
    // --- DEBUGGING LOG ---
    print("DEBUG GET BARANG URL: $url");
    // ---------------------

    final response = await http.get(url, headers: headers);

    // --- DEBUGGING LOG ---
    print("DEBUG STATUS BARANG: ${response.statusCode}");
    print("DEBUG BODY BARANG: ${response.body}");
    // ---------------------

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat data barang');
    }
  }

  Future<Map<String, dynamic>> getDetailBarang(int id) async {
    final url = Uri.parse('$baseUrl/barang/$id');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Barang tidak ditemukan');
    }
  }

  Future<bool> createBarang(Map<String, String> fields, File? imageFile, List<File>? additionalImages) async {
    final url = Uri.parse('$baseUrl/barang');
    final headers = await _getHeaders(isMultipart: true);

    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);

    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    if (imageFile != null) {
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'gambar', 
        stream, 
        length,
        filename: basename(imageFile.path)
      );
      request.files.add(multipartFile);
    }

    if (additionalImages != null && additionalImages.isNotEmpty) {
      for (var file in additionalImages) {
        var stream = http.ByteStream(file.openRead());
        var length = await file.length();
        var multipartFile = http.MultipartFile(
          'foto_lain[]',
          stream, 
          length,
          filename: basename(file.path)
        );
        request.files.add(multipartFile);
      }
    }

    var response = await request.send();
    if (response.statusCode == 201) {
      return true;
    } else {
      final respStr = await response.stream.bytesToString();
      throw Exception('Gagal upload barang: $respStr');
    }
  }

Future<bool> deleteBarang(int id) async {
    final url = Uri.parse('$baseUrl/barang/$id');
    final headers = await _getHeaders();
    
    print("DEBUG: Mencoba hapus barang ID $id"); // Debug 1

    final response = await http.delete(url, headers: headers);
    
    print("DEBUG STATUS DELETE: ${response.statusCode}"); // Debug 2
    print("DEBUG BODY DELETE: ${response.body}"); // Debug 3 <--- INI KUNCINYA

    if (response.statusCode == 200) {
      return true;
    } else {
      // Jangan throw exception, tapi return false biar gak crash, 
      // tapi kita sudah liat errornya di print atas.
      return false; 
    }
  }
    Future<bool> verifyBarang(int id) async {
    final url = Uri.parse('$baseUrl/barang/$id/verifikasi');
    final headers = await _getHeaders();

    try {
      final response = await http.patch(url, headers: headers);
      print("DEBUG VERIFIKASI: ${response.statusCode} - ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("Error Verifikasi: $e");
      return false;
    }
  }

  // ===========================================================================
  // KLAIM PENEMUAN
  // ===========================================================================

  Future<bool> createKlaim(Map<String, String> fields, File? fotoIdentitas) async {
    final url = Uri.parse('$baseUrl/klaim-penemuan'); 
    final headers = await _getHeaders(isMultipart: true);

    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);

    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    if (fotoIdentitas != null) {
      var stream = http.ByteStream(fotoIdentitas.openRead());
      var length = await fotoIdentitas.length();
      var multipartFile = http.MultipartFile(
        'foto_penemuan',
        stream, 
        length,
        filename: basename(fotoIdentitas.path)
      );
      request.files.add(multipartFile);
    }

    var response = await request.send();
    if (response.statusCode == 201) {
      return true;
    } else {
      final respStr = await response.stream.bytesToString();
      throw Exception('Gagal mengajukan klaim: $respStr');
    }
  }

  Future<List<dynamic>> getKlaimByBarang(int barangId) async {
    final url = Uri.parse('$baseUrl/klaim-penemuan?barang_id=$barangId');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Gagal mengambil data klaim');
    }
  }

  // ADMIN: Get All Klaim
  Future<List<dynamic>> getAllKlaim() async {
    final url = Uri.parse('$baseUrl/klaim-penemuan');
    try{ // Pastikan route ini ada di Laravel
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    print("DEBUG URL: $url");
    print("DEBUG STATUS: ${response.statusCode}");
    print("DEBUG BODY: ${response.body}");
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      print("SERVER ERROR: ${response.body}");
      throw Exception('Gagal mengambil data semua klaim. Status: ${response.statusCode}');
    }
  }catch (e) {
      print("CONNECTION ERROR: $e");
      rethrow;
  }
  }

  Future<bool> updateStatusKlaim(int klaimId, String status) async {
    final url = Uri.parse('$baseUrl/klaim-penemuan/$klaimId/status');
    final headers = await _getHeaders();
    
    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode({'status_klaim': status})
    );
    return response.statusCode == 200;
  }

  // ===========================================================================
  // BUKTI & MASTER DATA (Kategori, Lokasi, Notif)
  // ===========================================================================

  Future<bool> uploadBukti(int idBarang, File fotoBukti, String catatan) async {
    final url = Uri.parse('$baseUrl/bukti');
    final headers = await _getHeaders(isMultipart: true);

    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);

    request.fields['id_barang'] = idBarang.toString();
    request.fields['catatan'] = catatan;

    var stream = http.ByteStream(fotoBukti.openRead());
    var length = await fotoBukti.length();
    var multipartFile = http.MultipartFile(
      'foto_bukti',
      stream,
      length,
      filename: basename(fotoBukti.path)
    );
    request.files.add(multipartFile);

    var response = await request.send();
    if (response.statusCode == 201) {
      return true;
    } else {
      final respStr = await response.stream.bytesToString();
      throw Exception('Gagal upload bukti: $respStr');
    }
  }

  // ADMIN CRUD: KATEGORI
Future<List<dynamic>> getKategori() async {
  final url = Uri.parse('$baseUrl/kategori');

  try {
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    print('DEBUG KATEGORI URL: $url');
    print('DEBUG KATEGORI STATUS: ${response.statusCode}');
    print('DEBUG KATEGORI BODY: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception(
        'Gagal load kategori. Status: ${response.statusCode}, Body: ${response.body}'
      );
    }
  } catch (e) {
    print('KATEGORI CONNECTION ERROR: $e');
    rethrow;
  }
}


  Future<Map<String, dynamic>> createKategori(String nama, String deskripsi) async {
    final url = Uri.parse('$baseUrl/kategori');
    final headers = await _getHeaders();
    final response = await http.post(
      url, 
      headers: headers,
      body: jsonEncode({'nama_kategori': nama, 'deskripsi': deskripsi})
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Gagal tambah kategori');
    }
  }
  Future<bool> updateKategori(int id, String nama, String deskripsi) async {
    final url = Uri.parse('$baseUrl/kategori/$id');
    final headers = await _getHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode({'nama_kategori': nama, 'deskripsi': deskripsi}),
    );
    return response.statusCode == 200;
  }
  
Future<bool> deleteKategori(int id) async {
  final url = Uri.parse('$baseUrl/kategori/$id');

  try {
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);

    print('DEBUG DELETE Kategori URL: $url');
    print('DEBUG DELETE Kategori STATUS: ${response.statusCode}');
    print('DEBUG DELETE Kategori BODY: ${response.body}');

    return response.statusCode == 200;
  } catch (e) {
    print('DELETE Kategori CONNECTION ERROR: $e');
    return false;
  }
}


  // ADMIN CRUD: LOKASI
Future<List<dynamic>> getLokasi() async {
  final url = Uri.parse('$baseUrl/lokasi');

  try {
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    print('DEBUG LOKASI URL: $url');
    print('DEBUG LOKASI STATUS: ${response.statusCode}');
    print('DEBUG LOKASI BODY: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception(
        'Gagal load kategori. Status: ${response.statusCode}, Body: ${response.body}'
      );
    }
  } catch (e) {
    print('KATEGORI CONNECTION ERROR: $e');
    rethrow;
  }
}

  Future<Map<String, dynamic>> createLokasi(String nama, String deskripsi) async {
    final url = Uri.parse('$baseUrl/lokasi');
    final headers = await _getHeaders();
    final response = await http.post(
      url, 
      headers: headers,
      body: jsonEncode({'nama_lokasi': nama, 'deskripsi': deskripsi})
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Gagal tambah lokasi');
    }
  }
  Future<bool> updateLokasi(int id, String nama, String deskripsi) async {
    final url = Uri.parse('$baseUrl/lokasi/$id');
    final headers = await _getHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode({'nama_lokasi': nama, 'deskripsi': deskripsi}),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteLokasi(int id) async {
    final url = Uri.parse('$baseUrl/lokasi/$id');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);
    return response.statusCode == 200;
  }

// ===========================================================================
  // PROFILE MANAGEMENT
  // ===========================================================================

  Future<bool> updateProfile(int userId, Map<String, dynamic> data) async {
    // Sesuaikan endpoint backend Anda
    final url = Uri.parse('$baseUrl/user/$userId'); 
    final headers = await _getHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      // Update session user di lokal jika perlu
      final prefs = await SharedPreferences.getInstance();
      final responseBody = jsonDecode(response.body);
      if (responseBody['data'] != null) {
        // Simpan data terbaru ke shared_preferences
        await prefs.setString('user', jsonEncode(responseBody['data']));
      }
      return true;
    } else {
      // Log error untuk debugging
      print("Update Profile Failed: ${response.body}");
      return false;
    }
  }
  
  // NOTIFIKASI
  Future<List<dynamic>> getNotifikasi() async {
    final url = Uri.parse('$baseUrl/notifikasi');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}