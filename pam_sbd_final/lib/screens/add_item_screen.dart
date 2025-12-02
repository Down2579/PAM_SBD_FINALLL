import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:image_picker/image_picker.dart'; 

class AddItemScreen extends StatefulWidget {
  final File? imageFile; 

  const AddItemScreen({Key? key, this.imageFile}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
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
  String? _selectedCategory;

  // Variable Gambar
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.imageFile != null) {
      _selectedImage = widget.imageFile;
    }
  }

  // ================= 1. FUNGSI PILIH GAMBAR =================
  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Tutup Bottom Sheet
    try {
      final XFile? picked = await _picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // ================= 2. TAMPILKAN OPSI (BOTTOM SHEET) =================
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upload Image",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
              ),
              SizedBox(height: 20),
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

  Widget _buildOption(IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () => _pickImage(source),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
              border: Border.all(color: darkBlue.withOpacity(0.2)),
            ),
            child: Icon(icon, size: 30, color: darkBlue),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: textDark)),
        ],
      ),
    );
  }

  // ================= 3. FUNGSI PILIH TANGGAL =================
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Icon(Icons.notifications_none, color: textDark),
          SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 40, color: darkBlue),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("My Task", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark)),
                    Text("Found yours !", style: TextStyle(fontSize: 12, color: darkBlue, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
            SizedBox(height: 20),

            // === FORM CARD ===
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardGrey, // Background abu-abu
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildFormRow("Item name", _buildTextField(_nameController)),
                  SizedBox(height: 15),
                  _buildFormRow("Category", _buildDropdown()),
                  SizedBox(height: 15),
                  _buildFormRow("Date", _buildTextField(_dateController, isDate: true)),
                  SizedBox(height: 15),
                  _buildFormRow("Description", _buildTextField(_descController, maxLines: 4)),
                  SizedBox(height: 15),
                  
                  // === IMAGE PICKER SECTION ===
                  _buildFormRow(
                    "Image", 
                    GestureDetector(
                      onTap: _showImageSourceOptions, // Klik untuk munculkan pilihan
                      child: Container(
                        height: 120, // Tinggi kotak gambar
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        // Logika Tampilan
                        child: _selectedImage == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, color: Colors.grey, size: 30),
                                    SizedBox(height: 5),
                                    Text("Tap to add image", style: TextStyle(color: Colors.grey, fontSize: 12))
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover, // Agar gambar memenuhi kotak
                                  width: double.infinity,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Buttons Undo & Post
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text("Undo", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Logic Simpan ke API (Nanti)
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Task Posted!")));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text("Post", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= 4. HELPER WIDGETS =================

  // Helper Widget Label & Input
  Widget _buildFormRow(String label, Widget input) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text("$label  :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
          ),
        ),
        Expanded(child: input),
      ],
    );
  }

  // Helper TextField Putih
  Widget _buildTextField(TextEditingController controller, {bool isDate = false, int maxLines = 1}) {
    return GestureDetector(
      onTap: isDate ? _pickDate : null,
      child: AbsorbPointer(
        absorbing: isDate,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixIcon: isDate ? Icon(Icons.calendar_today, size: 18, color: Colors.grey) : null,
            ),
          ),
        ),
      ),
    );
  }

  // Helper Dropdown Putih (FIXED SYNTAX)
  Widget _buildDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          hint: Text("Select category", style: TextStyle(fontSize: 14, color: Colors.grey)),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: ["Elektronik", "Dokumen", "Pakaian", "Aksesoris", "Lainnya"].map((String value) {
            return DropdownMenuItem<String>(
              value: value, 
              child: Text(value, style: TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
      ),
    );
  }
}