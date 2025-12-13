import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../models.dart';

class ManageLokasiPage extends StatefulWidget {
  const ManageLokasiPage({super.key});

  @override
  State<ManageLokasiPage> createState() => _ManageLokasiPageState();
}

class _ManageLokasiPageState extends State<ManageLokasiPage> {
  final Color darkNavy = const Color(0xFF2B4263);
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color orangeBrand = const Color(0xFFF97316);
  final Color errorRed = const Color(0xFFEF4444);
  final Color accentBlue = const Color(0xFF4A90E2);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<GeneralProvider>(context, listen: false).loadMasterData()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Master Lokasi", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Atur titik lokasi & deskripsi", style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
      body: Consumer<GeneralProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator(color: orangeBrand));
          if (provider.lokasiList.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            onRefresh: () => provider.loadMasterData(),
            color: orangeBrand,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.lokasiList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildLocationCard(provider.lokasiList[index], provider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: darkNavy,
        icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
        label: const Text("Lokasi Baru", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showFormDialog(context, Provider.of<GeneralProvider>(context, listen: false), null),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Belum ada data lokasi", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildLocationCard(Lokasi item, GeneralProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: orangeBrand.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.place, color: orangeBrand, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaLokasi,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  item.deskripsi != null && item.deskripsi!.isNotEmpty 
                      ? item.deskripsi! 
                      : "Tidak ada deskripsi",
                  style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined, color: accentBlue, size: 20),
                onPressed: () => _showFormDialog(context, provider, item),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              IconButton(
                icon: Icon(Icons.delete_outline, color: errorRed, size: 20),
                onPressed: () => _confirmDelete(context, provider, item),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showFormDialog(BuildContext context, GeneralProvider provider, Lokasi? item) {
    final isEdit = item != null;
    final nameController = TextEditingController(text: isEdit ? item.namaLokasi : '');
    final descController = TextEditingController(text: isEdit ? item.deskripsi : '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEdit ? "Edit Lokasi" : "Tambah Lokasi", style: TextStyle(color: darkNavy, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nama Lokasi", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Contoh: Gedung A",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Deskripsi", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Detail lokasi...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Batal", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: darkNavy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              
              bool success;
              if (isEdit) {
                // Pastikan provider mendukung parameter deskripsi
                success = await provider.editLokasi(item.id, nameController.text.trim(), descController.text.trim());
              } else {
                success = await provider.addLokasi(nameController.text.trim(), descController.text.trim());
              }

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil menyimpan data"), backgroundColor: Colors.green));
              }
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, GeneralProvider provider, Lokasi item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Lokasi?"),
        content: Text("Yakin ingin menghapus '${item.namaLokasi}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteLokasi(item.id);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}