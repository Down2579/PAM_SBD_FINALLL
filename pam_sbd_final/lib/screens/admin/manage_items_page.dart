import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../models.dart';

class ManageItemsPage extends StatelessWidget {
  const ManageItemsPage({super.key});

  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Manage Items", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkNavy)),
                      const Text("Monitor & Selesaikan Laporan", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                )
              ],
            ),
          ),
          
          // List
          Expanded(
            child: Consumer<BarangProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.listBarang.isEmpty) return const Center(child: CircularProgressIndicator());
                
                return RefreshIndicator(
                  onRefresh: () => provider.fetchBarang(refresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: provider.listBarang.length,
                    itemBuilder: (ctx, i) => _buildItemCard(context, provider.listBarang[i]),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Barang item) {
    bool isProcess = item.status == 'proses_klaim';
    bool isDone = item.status == 'selesai';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))]
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: isProcess ? Colors.orange : (isDone ? Colors.green : darkNavy),
              borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(isProcess ? Icons.sync : (isDone ? Icons.check : Icons.inventory_2), color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.namaBarang, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkNavy)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isProcess ? Colors.orange : (isDone ? Colors.green : Colors.blue)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: Text(
                        item.status.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                          color: isProcess ? Colors.orange : (isDone ? Colors.green : Colors.blue)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.lokasi?.namaLokasi ?? "-", style: const TextStyle(fontSize: 11, color: Colors.grey))),
                  ],
                ),
              ],
            ),
          ),
          if (isProcess)
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green, size: 32),
              tooltip: "Selesaikan (Upload Bukti)",
              onPressed: () => _showBuktiDialog(context, item),
            )
        ],
      ),
    );
  }

  void _showBuktiDialog(BuildContext context, Barang item) {
    final noteController = TextEditingController();
    File? imageFile;
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Konfirmasi Pengambilan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: darkNavy)),
                const SizedBox(height: 8),
                const Text("Upload bukti foto serah terima barang.", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                
                GestureDetector(
                  onTap: () async {
                    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
                    if(picked != null) setState(() => imageFile = File(picked.path));
                  },
                  child: Container(
                    height: 150, width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      image: imageFile != null ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover) : null
                    ),
                    child: imageFile == null 
                      ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.camera_alt_rounded, color: accentBlue, size: 30),
                          Text("Ambil Foto Bukti", style: TextStyle(color: accentBlue, fontWeight: FontWeight.bold))
                        ])
                      : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: "Catatan (Opsional)",
                    filled: true, fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: darkNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () async {
                      if(imageFile == null) return;
                      Navigator.pop(context);
                      
                      bool success = await Provider.of<KlaimProvider>(context, listen: false)
                          .uploadBukti(item.id, imageFile!, noteController.text);
                      
                      if(success && context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Barang Selesai!"), backgroundColor: Colors.green));
                         Provider.of<BarangProvider>(context, listen: false).fetchBarang(refresh: true);
                      }
                    }, 
                    child: const Text("Konfirmasi Selesai", style: TextStyle(color: Colors.white))
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }
      ),
    );
  }
}