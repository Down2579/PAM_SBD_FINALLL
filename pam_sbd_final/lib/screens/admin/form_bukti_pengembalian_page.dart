import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers.dart'; // Sesuaikan path provider Anda
import '../../models.dart';
import '../../api_service.dart'; // Sesuaikan path api_service

class FormBuktiPengembalianPage extends StatefulWidget {
  final KlaimPenemuan klaim;

  const FormBuktiPengembalianPage({super.key, required this.klaim});

  @override
  State<FormBuktiPengembalianPage> createState() => _FormBuktiPengembalianPageState();
}

class _FormBuktiPengembalianPageState extends State<FormBuktiPengembalianPage> {
  File? _imageFile;
  final TextEditingController _catatanController = TextEditingController();
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
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
      final api = ApiService(); // Atau gunakan Provider jika sudah ada logic disana
      
      // 1. Upload Bukti
      await api.uploadBukti(
        widget.klaim.idBarang, 
        _imageFile!, 
        _catatanController.text.isEmpty ? "Barang telah dikembalikan kepada pemilik" : _catatanController.text
      );

      // 2. Update Status Klaim menjadi 'diterima_pemilik' (atau status final lainnya)
      // Gunakan provider untuk update status agar list di halaman sebelumnya ter-refresh
      await Provider.of<KlaimProvider>(context, listen: false)
          .updateStatus(widget.klaim.id, 'diterima_pemilik');

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Klaim berhasil diterima & bukti terupload")),
      );
      
      // Kembali ke halaman list
      Navigator.pop(context); 

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bukti Pengembalian")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Validasi Pengembalian Barang", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Upload foto serah terima barang antara Penemu dan Pemilik/Admin.", 
              style: TextStyle(color: Colors.grey[600])),
            
            const SizedBox(height: 20),
            
            // Image Picker Area
            GestureDetector(
              onTap: () => _showImageSourceModal(),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                          Text("Tap untuk ambil foto"),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
            TextField(
              controller: _catatanController,
              decoration: const InputDecoration(
                labelText: "Catatan Tambahan (Opsional)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitBukti,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B4263),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Konfirmasi Serah Terima", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Galeri'),
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