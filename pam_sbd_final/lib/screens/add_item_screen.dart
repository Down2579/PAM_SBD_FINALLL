import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers.dart'; // Pastikan path benar
import '../models.dart'; // Pastikan path benar

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // Form Key
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  // State Variables
  int? _selectedCategoryId;
  int? _selectedLocationId;
  String? _selectedReportType; // 'hilang' atau 'ditemukan'
  DateTime? _selectedDate;
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Colors Palette (Konsisten)
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGrey = const Color(0xFF9CA3AF);
  final Color inputFill = const Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    // Load Master Data (Kategori & Lokasi) via Provider saat masuk halaman
    Future.microtask(() => 
      Provider.of<GeneralProvider>(context, listen: false).loadMasterData()
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen providers
    final generalProvider = Provider.of<GeneralProvider>(context);
    final barangProvider = Provider.of<BarangProvider>(context);

    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: bgPage,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "New Report",
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER TEXT =================
              Text(
                "Item Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkNavy),
              ),
              const SizedBox(height: 8),
              Text(
                "Please fill in the details of the item found or lost.",
                style: TextStyle(color: textGrey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // ================= FORM CONTAINER =================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. NAMA BARANG
                    _buildLabel("Item Name"),
                    _buildTextField(
                      controller: _nameController,
                      hint: "e.g. Black Leather Wallet",
                      icon: Icons.edit_outlined,
                    ),
                    const SizedBox(height: 20),

                    // 2. KATEGORI (Dropdown dari Provider)
                    _buildLabel("Category"),
                    _buildDropdown<int>(
                      value: _selectedCategoryId,
                      hint: "Select Category",
                      icon: Icons.category_outlined,
                      items: generalProvider.kategoriList.map((e) {
                        return DropdownMenuItem(value: e.id, child: Text(e.namaKategori));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                    ),
                    const SizedBox(height: 20),

                    // 3. LOKASI (Dropdown dari Provider)
                    _buildLabel("Location"),
                    _buildDropdown<int>(
                      value: _selectedLocationId,
                      hint: "Select Location",
                      icon: Icons.location_on_outlined,
                      items: generalProvider.lokasiList.map((e) {
                        return DropdownMenuItem(value: e.id, child: Text(e.namaLokasi));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedLocationId = val),
                    ),
                    const SizedBox(height: 20),

                    // 4. TIPE LAPORAN
                    _buildLabel("Report Type"),
                    Row(
                      children: [
                        Expanded(child: _buildRadioButton("Lost", "hilang", Colors.redAccent)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildRadioButton("Found", "ditemukan", Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 5. TANGGAL
                    _buildLabel("Date"),
                    _buildDatePicker(),
                    const SizedBox(height: 20),

                    // 6. DESKRIPSI
                    _buildLabel("Description"),
                    _buildTextField(
                      controller: _descController,
                      hint: "Describe specific features...",
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // 7. GAMBAR
                    _buildLabel("Photo"),
                    _buildImagePickerBox(),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================= SUBMIT BUTTON =================
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: barangProvider.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: darkNavy.withOpacity(0.3),
                  ),
                  child: barangProvider.isLoading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Submit Report",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ================= LOGIC METHODS =================

Future<void> _handleSubmit() async {
    // ... (Validasi awal tetap sama) ...
    if (_nameController.text.isEmpty || 
        _selectedCategoryId == null || 
        _selectedLocationId == null ||
        _selectedReportType == null ||
        _selectedDate == null ||
        _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua data"), backgroundColor: Colors.red),
      );
      return;
    }

    // ... (Data Map tetap sama) ...
    final Map<String, String> data = {
      'nama_barang': _nameController.text,
      'deskripsi': _descController.text,
      'tipe_laporan': _selectedReportType!, 
      'id_kategori': _selectedCategoryId.toString(),
      'id_lokasi': _selectedLocationId.toString(),
      'tanggal_kejadian': DateFormat('yyyy-MM-dd').format(_selectedDate!),
    };

    // Panggil Provider
    // Pastikan provider mengirimkan image jika ada
    final success = await Provider.of<BarangProvider>(context, listen: false)
        .addBarang(data, _selectedImage, null); 

    if (success && mounted) {
      // 1. UPDATE PESAN AGAR LEBIH INFORMATIF
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Laporan berhasil dikirim! Cek menu 'My Task' untuk memantau status verifikasi."), 
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
      // 2. KIRIM 'true' SAAT KEMBALI
      // Ini memberitahu halaman sebelumnya untuk refresh list
      Navigator.pop(context, true); 
      
    } else if (mounted) {
      final msg = Provider.of<BarangProvider>(context, listen: false).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg ?? "Gagal mengirim laporan"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Tutup modal
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // ================= WIDGET BUILDERS =================

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: TextStyle(
          color: darkNavy,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: textDark, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: darkNavy),
          hint: Row(
            children: [
              Icon(icon, color: Colors.grey[500], size: 22),
              const SizedBox(width: 12),
              Text(hint, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
            ],
          ),
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildRadioButton(String label, String value, Color activeColor) {
    bool isSelected = _selectedReportType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedReportType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : inputFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : Colors.grey[500],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(primary: darkNavy),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: inputFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: Colors.grey[500], size: 22),
            const SizedBox(width: 12),
            Text(
              _selectedDate == null 
                  ? "Select Date" 
                  : DateFormat('dd MMMM yyyy').format(_selectedDate!),
              style: TextStyle(
                color: _selectedDate == null ? Colors.grey[400] : textDark,
                fontWeight: FontWeight.w600,
                fontSize: 14
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerBox() {
    return GestureDetector(
      onTap: () => _showImageSourceModal(),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: inputFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2), style: BorderStyle.solid),
          image: _selectedImage != null 
              ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
              : null
        ),
        child: _selectedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded, color: accentBlue, size: 40),
                  const SizedBox(height: 8),
                  Text("Upload Image", style: TextStyle(color: accentBlue, fontWeight: FontWeight.bold)),
                ],
              )
            : null,
      ),
    );
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 180,
        child: Column(
          children: [
            Text("Select Image Source", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkNavy)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(Icons.camera_alt_rounded, "Camera", ImageSource.camera),
                _buildSourceOption(Icons.photo_library_rounded, "Gallery", ImageSource.gallery),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () => _pickImage(source),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgPage,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: darkNavy),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: textDark)),
        ],
      ),
    );
  }
}