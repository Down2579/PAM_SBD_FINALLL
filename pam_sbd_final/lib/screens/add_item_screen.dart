// lib/screens/add_item_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../api_service.dart'; // pastikan path sesuai
// import '../providers.dart'; // optional jika mau pakai provider

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // Colors
  final Color darkBlue = const Color(0xFF2B4263);
  final Color textDark = const Color(0xFF1F1F1F);
  final Color cardGrey = const Color(0xFFE0E0E0);

  // Controllers
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _descController = TextEditingController();

  // Dropdown selections
  int? _selectedCategoryId;
  int? _selectedLocationId;
  String? _selectedReportType; // 'hilang' / 'ditemukan'

  // Local lists (loaded from API)
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _locations = [];

  // Image
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Loading state
  bool _loading = false;
  bool _loadingCategories = true;
  bool _loadingLocations = true;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('MM/dd/yyyy').format(DateTime.now());
    _loadCategories();
    _loadLocations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ================= Image picker =================
  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memilih gambar")),
      );
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SizedBox(
          height: 160,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 6,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(height: 12),
              Text("Upload Image", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOption(Icons.camera_alt_outlined, "Camera", ImageSource.camera),
                  _buildOption(Icons.photo_library_outlined, "Gallery", ImageSource.gallery),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(IconData icon, String label, ImageSource src) {
    return InkWell(
      onTap: () => _pickImage(src),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: darkBlue.withOpacity(0.2)),
            ),
            child: Icon(icon, size: 28, color: darkBlue),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: textDark, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ================= Date picker =================
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  // ================= Load kategori & lokasi dari API =================
  Future<Map<String, String>> _getAuthHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiService.baseUrl}/kategori');
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        // body can be: list OR { data: [...] } OR { success,message,data }
        List dataList = [];
        if (body is List) {
          dataList = body;
        } else if (body is Map && body['data'] != null && body['data'] is List) {
          dataList = body['data'];
        } else if (body is Map && body['kategori'] != null && body['kategori'] is List) {
          dataList = body['kategori'];
        } else {
          // try to find first list value
          dataList = (body as Map).values.firstWhere(
            (v) => v is List,
            orElse: () => [],
          );
        }

        _categories = dataList.map<Map<String, dynamic>>((e) {
          // normalize: expect at least id and nama_kategori
          return {
            'id': e['id'] ?? e['ID'] ?? e['Id'],
            'nama': e['nama_kategori'] ?? e['nama'] ?? e['nama_kategori'] ?? e['nama_kategori'],
          };
        }).toList();
      } else {
        debugPrint('Failed to load categories: ${res.body}');
      }
    } catch (e) {
      debugPrint('Error load categories: $e');
    } finally {
      setState(() => _loadingCategories = false);
    }
  }

  Future<void> _loadLocations() async {
    setState(() => _loadingLocations = true);
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiService.baseUrl}/lokasi');
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        List dataList = [];
        if (body is List) {
          dataList = body;
        } else if (body is Map && body['data'] != null && body['data'] is List) {
          dataList = body['data'];
        } else if (body is Map && body['lokasi'] != null && body['lokasi'] is List) {
          dataList = body['lokasi'];
        } else {
          dataList = (body as Map).values.firstWhere((v) => v is List, orElse: () => []);
        }

        _locations = dataList.map<Map<String, dynamic>>((e) {
          return {
            'id': e['id'] ?? e['ID'] ?? e['Id'],
            'nama': e['nama_lokasi'] ?? e['nama'] ?? e['nama_lokasi'],
          };
        }).toList();
      } else {
        debugPrint('Failed to load locations: ${res.body}');
      }
    } catch (e) {
      debugPrint('Error load locations: $e');
    } finally {
      setState(() => _loadingLocations = false);
    }
  }

  // ================= Submit form ( pakai ApiService.createItem ) =================
  Future<void> _submitForm() async {
    // Validasi sederhana
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nama barang wajib diisi")));
      return;
    }
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deskripsi wajib diisi")));
      return;
    }
    if (_selectedReportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih tipe laporan")));
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih kategori")));
      return;
    }
    if (_selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih lokasi")));
      return;
    }
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload gambar utama")));
      return;
    }

    setState(() => _loading = true);

    try {
      // convert date to yyyy-MM-dd
      String tanggal = '';
      try {
        final parsed = DateFormat('MM/dd/yyyy').parse(_dateController.text);
        tanggal = DateFormat('yyyy-MM-dd').format(parsed);
      } catch (_) {
        tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
      }

      // data fields as strings
      final data = <String, String>{
        'nama_barang': _nameController.text.trim(),
        'deskripsi': _descController.text.trim(),
        'tipe_laporan': _selectedReportType!, // 'hilang' or 'ditemukan'
        'tanggal_kejadian': tanggal,
        'id_kategori': _selectedCategoryId.toString(),
        'id_lokasi': _selectedLocationId.toString(),
      };

      // call ApiService
      final api = ApiService();
      final success = await api.createItem(data: data, imageFile: _selectedImage);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Barang berhasil ditambahkan")));
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menambahkan barang")));
      }
    } catch (e) {
      debugPrint("Submit error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tambah Barang"),
        backgroundColor: darkBlue,
      ),
      body: _loadingCategories || _loadingLocations
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama
                    const SizedBox(height: 6),
                    const Text("Nama Barang", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    _buildTextField(_nameController, hint: "Contoh: Dompet hitam"),

                    const SizedBox(height: 12),
                    // Kategori
                    const Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    _buildCategoryDropdown(),

                    const SizedBox(height: 12),
                    // Lokasi
                    const Text("Lokasi", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    _buildLocationDropdown(),

                    const SizedBox(height: 12),
                    // Tipe Laporan
                    const Text("Tipe Laporan", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    _buildReportTypeDropdown(),

                    const SizedBox(height: 12),
                    // Tanggal
                    const Text("Tanggal Kejadian", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    _buildDateField(),

                    const SizedBox(height: 12),
                    const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    _buildMultilineField(_descController),

                    const SizedBox(height: 12),
                    const Text("Gambar Utama", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    _buildImagePicker(),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Batal"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _loading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(backgroundColor: darkBlue),
                          child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Post"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController c, {String hint = ""}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: TextField(
        controller: c,
        decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), border: InputBorder.none, hintText: hint),
      ),
    );
  }

  Widget _buildMultilineField(TextEditingController c) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: TextField(
        controller: c,
        maxLines: 5,
        decoration: const InputDecoration(contentPadding: EdgeInsets.all(12), border: InputBorder.none, hintText: "Deskripsikan lokasi/warna/ciri-ciri"),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
          child: TextField(
            controller: _dateController,
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), border: InputBorder.none, suffixIcon: Icon(Icons.calendar_today)),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedCategoryId,
          isExpanded: true,
          hint: const Text("Pilih kategori"),
          items: _categories.map((c) {
            return DropdownMenuItem<int>(
              value: c['id'] as int?,
              child: Text(c['nama']?.toString() ?? '-'),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedCategoryId = val),
        ),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedLocationId,
          isExpanded: true,
          hint: const Text("Pilih lokasi"),
          items: _locations.map((c) {
            return DropdownMenuItem<int>(
              value: c['id'] as int?,
              child: Text(c['nama']?.toString() ?? '-'),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedLocationId = val),
        ),
      ),
    );
  }

  Widget _buildReportTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedReportType,
          isExpanded: true,
          hint: const Text("Pilih tipe"),
          items: const [
            DropdownMenuItem(value: "hilang", child: Text("Barang Hilang")),
            DropdownMenuItem(value: "ditemukan", child: Text("Barang Ditemukan")),
          ],
          onChanged: (val) => setState(() => _selectedReportType = val),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourceOptions,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
        child: _selectedImage == null
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.add_a_photo, size: 32, color: Colors.grey), SizedBox(height: 8), Text("Tap to add image", style: TextStyle(color: Colors.grey))]))
            : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity)),
      ),
    );
  }
}
