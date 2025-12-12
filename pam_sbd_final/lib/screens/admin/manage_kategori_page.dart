import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../models.dart';

class ManageKategoriPage extends StatelessWidget {
  const ManageKategoriPage({super.key});

  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color bgPage = const Color(0xFFF5F7FA);

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
                      Text("Master Kategori", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkNavy)),
                      Text("Atur jenis barang (Electronics, dll)", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                    ),
                    child: Icon(Icons.category_rounded, color: darkNavy, size: 28),
                  )
                ],
              ),
            ),
            
            // LIST ITEM
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: generalProvider.kategoriList.length,
                itemBuilder: (context, index) {
                  final item = generalProvider.kategoriList[index];
                  return _buildModernCard(context, generalProvider, item);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: darkNavy,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Category", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showFormDialog(context, generalProvider, null),
      ),
    );
  }

  Widget _buildModernCard(BuildContext context, GeneralProvider provider, Kategori item) {
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
            gradient: LinearGradient(
              colors: [darkNavy.withOpacity(0.1), darkNavy.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.label_outline_rounded, color: darkNavy, size: 22),
        ),
        title: Text(
          item.namaKategori,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // EDIT BUTTON
            IconButton(
              icon: Icon(Icons.edit_rounded, color: accentBlue, size: 22),
              onPressed: () => _showFormDialog(context, provider, item),
              tooltip: "Edit",
            ),
            // DELETE BUTTON
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: Colors.red[300], size: 22),
              onPressed: () => _confirmDelete(context, provider, item),
              tooltip: "Delete",
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE DIALOG FOR ADD & EDIT ---
  void _showFormDialog(BuildContext context, GeneralProvider provider, Kategori? item) {
    final isEdit = item != null;
    final controller = TextEditingController(text: isEdit ? item.namaKategori : '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(isEdit ? Icons.edit_note_rounded : Icons.add_circle_outline, color: darkNavy),
            const SizedBox(width: 10),
            Text(isEdit ? "Edit Category" : "New Category", style: TextStyle(color: darkNavy, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              style: TextStyle(color: Colors.grey[800]),
              decoration: InputDecoration(
                hintText: "Category Name (e.g. Electronics)",
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: bgPage,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: darkNavy, width: 1.5)),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                success = await provider.editKategori(item.id, controller.text.trim());
              } else {
                success = await provider.addKategori(controller.text.trim());
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

  void _confirmDelete(BuildContext context, GeneralProvider provider, Kategori item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Kategori?"),
        content: Text("Yakin ingin menghapus '${item.namaKategori}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              bool success = await provider.deleteKategori(item.id);
              if (!success) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghapus")));
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}