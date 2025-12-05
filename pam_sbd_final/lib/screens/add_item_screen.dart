import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../api_service.dart';
import 'home_screen.dart'; // Penting untuk navigasi kembali
import 'help_center_screen.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // --- Controllers & State Variables ---
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;

  int? _selectedCategoryId;
  int? _selectedLocationId;
  String? _selectedReportType;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _locations = [];

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _loading = false;
  bool _loadingData = true;

  // --- Palet Warna Sesuai Desain ---
  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);
  final Color bgForm = Colors.white;
  final Color bgInput = const Color(0xFFF5F7FA);
  final Color bgTop = const Color(0xFFF5F7FA);
  final Color bgBottom = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- FUNGSI-FUNGSI LOGIKA ---

  Future<void> _loadInitialData() async {
    await Future.wait([_loadCategories(), _loadLocations()]);
    if (mounted) setState(() => _loadingData = false);
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SizedBox(
        height: 160,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6))),
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
      ),
    );
  }

  Widget _buildOption(IconData icon, String label, ImageSource src) {
    return InkWell(
      onTap: () => _pickImage(src),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: darkNavy.withOpacity(0.2))),
            child: Icon(icon, size: 28, color: darkNavy),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: textDark, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return {'Accept': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
  }

  Future<void> _loadCategories() async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiService.baseUrl}/kategori');
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        List dataList = (body['data'] as List?) ?? [];
        if (mounted) {
          setState(() {
            _categories = dataList.map<Map<String, dynamic>>((e) => {'id': e['id'], 'nama': e['nama_kategori']}).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error load categories: $e');
    }
  }

  Future<void> _loadLocations() async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiService.baseUrl}/lokasi');
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        List dataList = (body['data'] as List?) ?? [];
        if (mounted) {
          setState(() {
            _locations = dataList.map<Map<String, dynamic>>((e) => {'id': e['id'], 'nama': e['nama_lokasi']}).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error load locations: $e');
    }
  }

  Future<void> _submitForm() async {
    // 1. Validasi semua field wajib
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar("Nama barang tidak boleh kosong!", isError: true);
      return;
    }
    if (_selectedCategoryId == null) {
      _showSnackBar("Pilih kategori!", isError: true);
      return;
    }
    if (_selectedLocationId == null) {
      _showSnackBar("Pilih lokasi!", isError: true);
      return;
    }
    if (_selectedReportType == null) {
      _showSnackBar("Pilih tipe laporan!", isError: true);
      return;
    }
    if (_selectedDate == null) {
      _showSnackBar("Pilih tanggal kejadian!", isError: true);
      return;
    }
    if (_descController.text.trim().isEmpty) {
      _showSnackBar("Deskripsi tidak boleh kosong!", isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      // 2. Siapkan data untuk dikirim
      final Map<String, String> formData = {
        'nama_barang': _nameController.text.trim(),
        'id_kategori': _selectedCategoryId.toString(),
        'id_lokasi': _selectedLocationId.toString(),
        'tipe_laporan': _selectedReportType!,
        'waktu': _selectedDate.toString().split(' ')[0], // Format: YYYY-MM-DD
        'deskripsi': _descController.text.trim(),
      };

      // 3. Submit ke backend dengan image
      final ApiService api = ApiService();
      bool success = await api.createItem(
        data: formData,
        imageFile: _selectedImage,
      );

      if (success) {
        _showSnackBar("Laporan berhasil dibuat!", isError: false);
        
        // Tunggu 2 detik sebelum navigate kembali
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          // Navigate kembali ke HomeScreen di tab My Task
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(initialIndex: 1),
            ),
            (route) => false,
          );
        }
      } else {
        _showSnackBar("Gagal membuat laporan. Coba lagi!", isError: true);
      }
    } catch (e) {
      print("Error submit form: $e");
      _showSnackBar("Error: ${e.toString()}", isError: true);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  // ================= UI BUILD METHOD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgTop,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: textDark, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_outlined, color: textDark, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HelpCenterScreen())),
          ),
        ],
      ),
      body: _loadingData
          ? Center(child: CircularProgressIndicator(color: darkNavy))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildFormCard(),
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(initialIndex: index)),
            (route) => false,
          );
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: darkNavy,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Task"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: "Completed"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), label: "Profile"),
        ],
      ),
    );
  }

  // --- WIDGET-WIDGET BUILDER ---

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Icon(Icons.inventory_2_outlined, color: darkNavy, size: 32),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Task", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textDark)),
            Text("Found yours !", style: TextStyle(fontSize: 14, color: darkNavy, fontWeight: FontWeight.w600)),
          ],
        )
      ],
    );
  }
  
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: bgForm,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: Column(
        children: [
          _buildFormRow("Nama Barang", _buildTextField("Contoh: Dompet ...", _nameController)),
          _buildFormRow("Kategori", _buildDropdown(_selectedCategoryId, _categories, "Pilih kategori", (val) => setState(() => _selectedCategoryId = val))),
          _buildFormRow("Lokasi", _buildDropdown(_selectedLocationId, _locations, "Pilih lokasi", (val) => setState(() => _selectedLocationId = val))),
          _buildFormRow("Tipe Laporan", _buildReportTypeDropdown()),
          _buildFormRow("Tanggal Kejadian", _buildDateField()),
          _buildFormRow("Deskripsi", _buildTextArea("Deskripsikan lokasi/warna/ciri-ciri", _descController), alignStart: true),
          _buildFormRow("Gambar Utama", _buildImagePicker(), alignStart: true),
        ],
      ),
    );
  }

  Widget _buildFormRow(String label, Widget child, {bool alignStart = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: textDark)),
          ),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: bgInput,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (val) => val!.isEmpty ? 'Tidak boleh kosong' : null,
    );
  }

  Widget _buildDropdown(int? value, List<Map<String, dynamic>> items, String hint, Function(int?) onChanged) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: bgInput, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: Colors.grey[600])),
          items: items.map((item) => DropdownMenuItem<int>(value: item['id'], child: Text(item['nama']))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildReportTypeDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: bgInput, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedReportType,
          isExpanded: true,
          hint: Text("Pilih tipe", style: TextStyle(color: Colors.grey[600])),
          items: const [
            DropdownMenuItem(value: "hilang", child: Text("Barang Hilang")),
            DropdownMenuItem(value: "ditemukan", child: Text("Barang Ditemukan")),
          ],
          onChanged: (val) => setState(() => _selectedReportType = val),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () => _pickDate(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(color: bgInput, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate == null ? '12/04/2025' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
              style: TextStyle(color: textDark, fontSize: 14),
            ),
            Icon(Icons.calendar_today_outlined, color: textDark, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextArea(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: bgInput,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: (val) => val!.isEmpty ? 'Tidak boleh kosong' : null,
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _showImageSourceOptions,
      child: Container(
        height: 100,
        decoration: BoxDecoration(color: bgInput, borderRadius: BorderRadius.circular(12)),
        child: _selectedImage == null
            ? Center(child: Icon(Icons.add_a_photo_outlined, color: Colors.grey[600], size: 40))
            : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedImage!, fit: BoxFit.cover)),
      ),
    );
  }
  
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkNavy,
          disabledBackgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        icon: _loading 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.check_circle, color: Colors.white, size: 20),
        label: Text(
          _loading ? "Submitting..." : "Submit Laporan",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}