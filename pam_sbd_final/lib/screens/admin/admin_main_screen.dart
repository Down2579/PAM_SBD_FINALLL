import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../models.dart';
import 'manage_klaim_page.dart';
import 'manage_kategori_page.dart';
import 'manage_lokasi_page.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  // Palette Warna Konsisten
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();
    // Load Data Awal
    Future.microtask(() {
      Provider.of<BarangProvider>(context, listen: false).fetchBarang(refresh: true);
      Provider.of<GeneralProvider>(context, listen: false).loadMasterData();
      Provider.of<KlaimProvider>(context, listen: false).fetchAllKlaim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildItemsManager(),      
      const ManageKlaimPage(),    
      const ManageKategoriPage(), 
      const ManageLokasiPage(),   
    ];

    return Scaffold(
      backgroundColor: bgPage,
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: darkNavy,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Items"),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in_rounded), label: "Klaim"),
            BottomNavigationBarItem(icon: Icon(Icons.category_rounded), label: "Kategori"),
            BottomNavigationBarItem(icon: Icon(Icons.location_on_rounded), label: "Lokasi"),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: MANAGE ITEMS ---
  Widget _buildItemsManager() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader("Manage Items", "Monitor status barang"),
          Expanded(
            child: Consumer<BarangProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.listBarang.isEmpty) {
                  return Center(child: CircularProgressIndicator(color: darkNavy));
                }
                
                return RefreshIndicator(
                  onRefresh: () => provider.fetchBarang(refresh: true),
                  color: darkNavy,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: provider.listBarang.length,
                    itemBuilder: (context, index) {
                      final item = provider.listBarang[index];
                      return _buildItemCard(item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: bgPage,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
            ),
            child: Image.asset('assets/images/logo.png', height: 40, width: 40, errorBuilder: (_,__,___) => Icon(Icons.admin_panel_settings, color: darkNavy)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkNavy)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/'); // Reset ke splash/login
            },
          )
        ],
      ),
    );
  }

  Widget _buildItemCard(Barang item) {
    bool isCompleted = item.status == 'selesai';
    bool inProcess = item.status == 'proses_klaim';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : (inProcess ? Colors.orange : darkNavy),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCompleted ? Icons.check : (inProcess ? Icons.sync : Icons.inventory_2), 
              color: Colors.white
            ),
          ),
          const SizedBox(width: 16),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.namaBarang, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (inProcess ? Colors.orange : (isCompleted ? Colors.green : Colors.blue)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: Text(
                        item.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                          color: inProcess ? Colors.orange : (isCompleted ? Colors.green : Colors.blue)
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.lokasi?.namaLokasi ?? "-", style: const TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          // Action Button
          if (inProcess)
            IconButton(
              icon: const Icon(Icons.check_circle_rounded, color: Colors.grey, size: 32),
              tooltip: "Selesaikan Klaim",
              onPressed: () => _showBuktiDialog(item),
            )
          else if (isCompleted)
             const Icon(Icons.verified_rounded, color: Colors.green, size: 28)
        ],
      ),
    );
  }

  void _showBuktiDialog(Barang item) {
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
                Text("Upload bukti foto serah terima barang.", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 20),
                
                // Image Picker
                GestureDetector(
                  onTap: () async {
                    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
                    if(picked != null) setState(() => imageFile = File(picked.path));
                  },
                  child: Container(
                    height: 150, width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgPage,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      image: imageFile != null ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover) : null
                    ),
                    child: imageFile == null 
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_rounded, color: accentBlue, size: 30),
                            const SizedBox(height: 8),
                            Text("Ambil Foto Bukti", style: TextStyle(color: accentBlue, fontWeight: FontWeight.bold))
                          ],
                        )
                      : null,
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: "Catatan (Opsional)",
                    filled: true, fillColor: bgPage,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                  ),
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkNavy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                    ),
                    onPressed: () async {
                      if(imageFile == null) return;
                      Navigator.pop(context); // Close dialog
                      
                      // Process Upload
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mengupload bukti...")));
                      
                      bool success = await Provider.of<KlaimProvider>(context, listen: false)
                          .uploadBukti(item.id, imageFile!, noteController.text);
                      
                      if(success) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil! Barang selesai."), backgroundColor: Colors.green));
                         Provider.of<BarangProvider>(context, listen: false).fetchBarang(refresh: true);
                      } else {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal upload bukti."), backgroundColor: Colors.red));
                      }
                    }, 
                    child: const Text("Konfirmasi Selesai", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
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