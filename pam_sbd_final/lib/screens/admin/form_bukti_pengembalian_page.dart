import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../models.dart';

class FormBuktiPengembalianPage extends StatefulWidget {
  final KlaimPenemuan klaim;

  const FormBuktiPengembalianPage({super.key, required this.klaim});

  @override
  State<FormBuktiPengembalianPage> createState() => _FormBuktiPengembalianPageState();
}

class _FormBuktiPengembalianPageState extends State<FormBuktiPengembalianPage> {
  // Palette Warna Konsisten
  final Color darkNavy = const Color(0xFF2B4263);
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color accentBlue = const Color(0xFF4A90E2);

  File? _imageFile;
  final TextEditingController _catatanController = TextEditingController();
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitBukti() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap sertakan foto bukti serah terima")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload Bukti & Catatan
      // Pastikan KlaimProvider memiliki method uploadBukti
      final success = await Provider.of<KlaimProvider>(context, listen: false)
          .uploadBukti(
            widget.klaim.idBarang, 
            _imageFile!, 
            _catatanController.text.isEmpty ? "Barang telah dikembalikan kepada pemilik" : _catatanController.text
          );

      if (!success) throw Exception("Gagal upload bukti");

      // 2. Update Status Klaim menjadi 'diterima_pemilik' (Finalisasi)
      await Provider.of<KlaimProvider>(context, listen: false)
          .updateStatus(widget.klaim.id, 'diterima_pemilik');

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil! Klaim disetujui & Barang Selesai."), 
          backgroundColor: Colors.green
        )
      );
      
      // Kembali ke halaman list dan otomatis refresh di sana
      Navigator.pop(context); 

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final barang = widget.klaim.barang;
    final penemu = widget.klaim.penemu;

    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        title: const Text("Finalisasi Klaim", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER INFO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: darkNavy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Upload Bukti Pengembalian",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Pastikan barang sudah diserahkan kepada pengklaim yang valid.",
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD RINGKASAN DATA
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.inventory_2, "Barang", barang?.namaBarang ?? "ID: ${widget.klaim.idBarang}"),
                        const Divider(height: 20),
                        _buildInfoRow(Icons.person, "Diklaim Oleh", penemu?.namaLengkap ?? "ID: ${widget.klaim.idPenemu}"),
                        const Divider(height: 20),
                        _buildInfoRow(Icons.access_time, "Waktu Klaim", widget.klaim.createdAt.toString().substring(0, 16)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text("Foto Bukti Serah Terima", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),

                  // IMAGE UPLOAD AREA
                  GestureDetector(
                    onTap: () => _showImageSourceModal(),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.5),
                        image: _imageFile != null 
                          ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                          : null
                      ),
                      child: _imageFile == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_rounded, size: 40, color: accentBlue),
                                const SizedBox(height: 8),
                                Text("Tap untuk ambil foto", style: TextStyle(color: accentBlue, fontWeight: FontWeight.bold)),
                              ],
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text("Catatan Admin (Opsional)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),

                  // TEXT FIELD
                  TextField(
                    controller: _catatanController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Contoh: Barang telah diambil oleh ybs di pos satpam...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitBukti,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("Konfirmasi & Selesai", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        )
      ],
    );
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Ambil Foto dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.purple),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}