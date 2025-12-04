import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../api_service.dart';
import 'notification_screen.dart';
import 'help_center_screen.dart';
import '../widgets/notification_modal.dart';
import 'home_screen.dart';
import 'my_task_screen.dart';
import 'completed_screen.dart';
import 'profile_screen.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // --- Controllers & State Variables ---
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _descController = TextEditingController();

  int? _selectedCategoryId;
  int? _selectedLocationId; // Ditambahkan kembali
  String? _selectedReportType; // Ditambahkan kembali

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _locations = []; // Ditambahkan kembali

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _loading = false;
  bool _loadingData = true;

  // --- Palet Warna ---
  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);
  final Color textSecondary = const Color(0xFF6B7280);
  final Color bgGrey = const Color(0xFFF5F7FA);
  final Color bgBlueLight = const Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('MM/dd/yyyy').format(DateTime.now());
    _loadInitialData();
  }
  
  // --- LOGIKA DATA (Fungsi tidak diubah, hanya ditambahkan _loadLocations) ---

  Future<void> _loadInitialData() async {
    // Memuat kategori dan lokasi secara bersamaan
    await Future.wait([
      _loadCategories(),
      _loadLocations(),
    ]);
    if (mounted) {
      setState(() => _loadingData = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _descController.dispose();
    super.dispose();
  }

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
    if (_nameController.text.trim().isEmpty || 
        _selectedCategoryId == null || 
        _selectedLocationId == null || 
        _selectedReportType == null || 
        _descController.text.trim().isEmpty || 
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap isi semua field yang wajib")));
      return;
    }
    setState(() => _loading = true);
    try {
      String tanggal = DateFormat('yyyy-MM-dd').format(DateFormat('MM/dd/yyyy').parse(_dateController.text));
      
      final data = <String, String>{
        'nama_barang': _nameController.text.trim(),
        'deskripsi': _descController.text.trim(),
        'tipe_laporan': _selectedReportType!,
        'tanggal_kejadian': tanggal,
        'id_kategori': _selectedCategoryId.toString(),
        'id_lokasi': _selectedLocationId.toString(),
      };
      
      final api = ApiService();
      final success = await api.createItem(data: data, imageFile: _selectedImage);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Barang berhasil ditambahkan")));
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menambahkan barang")));
      }
    } catch (e) {
      debugPrint("Submit error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================= UI BARU YANG LENGKAP =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBlueLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loadingData
                  ? Center(child: CircularProgressIndicator(color: darkNavy))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                      child: _buildFormCard(),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          else if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyTaskScreen()));
          else if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CompletedScreen()));
          else if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.menu, size: 28, color: textDark),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpCenterScreen()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.notifications_none_outlined, size: 28, color: textDark),
                onPressed: () async {
                  await showNotificationsModal(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                height: 60, width: 60, padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Image.asset('assets/images/logo.png', errorBuilder: (ctx, err, st) => Icon(Icons.error)),
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
          ),
        ],
      ),
    );
  }
  
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(
        children: [
          _buildFormRow("Nama Barang", _buildTextField(_nameController, "Contoh: Dompet hitam")),
          const SizedBox(height: 16),
          _buildFormRow("Kategori", _buildCategoryDropdown()),
          const SizedBox(height: 16),
          _buildFormRow("Lokasi", _buildLocationDropdown()), // DITAMBAHKAN
          const SizedBox(height: 16),
          _buildFormRow("Tipe Laporan", _buildReportTypeDropdown()), // DITAMBAHKAN
          const SizedBox(height: 16),
          _buildFormRow("Tanggal Kejadian", _buildDateField()),
          const SizedBox(height: 16),
          _buildFormRow("Deskripsi", _buildMultilineField(_descController), alignStart: true),
          const SizedBox(height: 16),
          _buildFormRow("Gambar Utama", _buildImagePicker(), alignStart: true),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildFormRow(String label, Widget child, {bool alignStart = false}) {
    return Row(
      crossAxisAlignment: alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 110, // Lebar label disesuaikan
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildTextField(TextEditingController c, String hint) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          filled: true,
          fillColor: bgBlueLight,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  // WIDGET BARU
  Widget _buildLocationDropdown() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: bgBlueLight, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedLocationId,
          isExpanded: true,
          hint: const Text("Pilih lokasi"),
          items: _locations.map((loc) {
            return DropdownMenuItem<int>(
              value: loc['id'],
              child: Text(loc['nama']),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedLocationId = val),
        ),
      ),
    );
  }

  // WIDGET BARU
  Widget _buildReportTypeDropdown() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: bgBlueLight, borderRadius: BorderRadius.circular(12)),
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

  Widget _buildCategoryDropdown() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: bgBlueLight, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedCategoryId,
          isExpanded: true,
          hint: const Text("Pilih kategori"),
          items: _categories.map((c) {
            return DropdownMenuItem<int>(
              value: c['id'],
              child: Text(c['nama']),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedCategoryId = val),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: SizedBox(
          height: 45,
          child: TextField(
            controller: _dateController,
            decoration: InputDecoration(
              filled: true,
              fillColor: bgBlueLight,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              suffixIcon: Icon(Icons.calendar_today, color: darkNavy),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultilineField(TextEditingController c) {
    return TextField(
      controller: c,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "Deskripsikan lokasi/warna/ciri-ciri",
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: bgBlueLight,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourceOptions,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(color: bgBlueLight, borderRadius: BorderRadius.circular(12)),
        child: _selectedImage == null
            ? Center(child: Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[600]))
            : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedImage!, fit: BoxFit.cover)),
      ),
    );
  }

   Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () {
            _nameController.clear();
            _descController.clear();
            setState(() {
              _selectedCategoryId = null;
              _selectedLocationId = null;
              _selectedReportType = null;
              _selectedImage = null;
              _dateController.text = DateFormat('MM/dd/yyyy').format(DateTime.now());
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: Text("Undo", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _loading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: darkNavy,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: _loading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
            : Text("Post", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}