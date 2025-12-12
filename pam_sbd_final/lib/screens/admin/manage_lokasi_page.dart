import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../models.dart';

class ManageLokasiPage extends StatelessWidget {
  const ManageLokasiPage({super.key});

  final Color darkNavy = const Color(0xFF2B4263);
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color orangeBrand = const Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    final generalProvider = Provider.of<GeneralProvider>(context);

    return Scaffold(
      backgroundColor: bgPage,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER MODERN
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Master Lokasi", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkNavy)),
                      Text("Atur titik lokasi kampus", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                    ),
                    child: Icon(Icons.map_rounded, color: orangeBrand, size: 28),
                  )
                ],
              ),
            ),
            
            // LIST ITEM
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: generalProvider.lokasiList.length,
                itemBuilder: (context, index) {
                  final item = generalProvider.lokasiList[index];
                  return _buildModernCard(context, generalProvider, item);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: darkNavy,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text("New Location", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showFormDialog(context, generalProvider, null),
      ),
    );
  }

  Widget _buildModernCard(BuildContext context, GeneralProvider provider, Lokasi item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFFE5E7EB).withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: orangeBrand.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.place_rounded, color: orangeBrand, size: 22),
        ),
        title: Text(
          item.namaLokasi,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 22),
              onPressed: () => _showFormDialog(context, provider, item),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: Colors.red[300], size: 22),
              onPressed: () => _confirmDelete(context, provider, item),
            ),
          ],
        ),
      ),
    );
  }

  void _showFormDialog(BuildContext context, GeneralProvider provider, Lokasi? item) {
    final isEdit = item != null;
    final controller = TextEditingController(text: isEdit ? item.namaLokasi : '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(isEdit ? Icons.edit_location_alt_rounded : Icons.add_location_alt_rounded, color: darkNavy),
            const SizedBox(width: 10),
            Text(isEdit ? "Edit Location" : "New Location", style: TextStyle(color: darkNavy, fontWeight: FontWeight.bold)),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Location Name (e.g. Gedung B)",
            filled: true,
            fillColor: bgPage,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: darkNavy,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              
              bool success;
              if (isEdit) {
                success = await provider.editLokasi(item.id, controller.text.trim());
              } else {
                success = await provider.addLokasi(controller.text.trim());
              }

              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? "Gagal update" : "Gagal tambah"), backgroundColor: Colors.red));
              }
            },
            child: Text(isEdit ? "Update" : "Create", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              bool success = await provider.deleteLokasi(item.id);
              if (!success) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghapus")));
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}