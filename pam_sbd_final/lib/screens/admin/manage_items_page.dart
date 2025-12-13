import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../models.dart';

class ManageItemsPage extends StatefulWidget {
  const ManageItemsPage({super.key});

  @override
  State<ManageItemsPage> createState() => _ManageItemsPageState();
}

class _ManageItemsPageState extends State<ManageItemsPage> {
  // Palette Warna Konsisten
  final Color darkNavy = const Color(0xFF2B4263);
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color errorRed = const Color(0xFFEF4444);
  final Color successGreen = const Color(0xFF10B981);
  final Color warningOrange = const Color(0xFFF59E0B);

  // URL Base untuk gambar (sesuaikan jika perlu)
  final String baseUrlImage = 'http://10.0.2.2:8000'; 

  @override
  void initState() {
    super.initState();
    // Fetch data saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BarangProvider>(context, listen: false).fetchBarang(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      // 1. HEADER KONSISTEN (APP BAR)
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Validasi Barang", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Kelola semua laporan barang", style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => Provider.of<BarangProvider>(context, listen: false).fetchBarang(refresh: true),
          )
        ],
      ),
      
      // 2. LIST DATA
      body: Consumer<BarangProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator(color: darkNavy));
          }

          if (provider.listBarang.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchBarang(refresh: true),
            color: darkNavy,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.listBarang.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildItemCard(context, provider, provider.listBarang[index]);
              },
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Tidak ada data barang", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, BarangProvider provider, Barang item) {
    // Tentukan Warna & Teks Status
    Color statusColor;
    String statusText;

    switch (item.status) {
      case 'selesai':
        statusColor = successGreen;
        statusText = "SELESAI";
        break;
      case 'proses_klaim':
        statusColor = warningOrange;
        statusText = "PROSES KLAIM";
        break;
      default:
        statusColor = Colors.blue;
        statusText = "OPEN";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FOTO BARANG (Thumbnail)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 70, height: 70,
                  color: Colors.grey[100],
                  child: item.gambarUrl != null && item.gambarUrl!.isNotEmpty
                      ? Image.network(
                          item.gambarUrl!.startsWith('http') ? item.gambarUrl! : baseUrlImage + item.gambarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) => const Icon(Icons.broken_image, color: Colors.grey),
                        )
                      : Icon(Icons.image, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(width: 12),
              
              // INFO TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.namaBarang,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkNavy),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Badge Status Kecil
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Info Kategori & Lokasi
                    Text(
                      "${item.kategori?.namaKategori ?? '-'} • ${item.lokasi?.namaLokasi ?? '-'}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    // Info Pelapor
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.pelapor?.namaLengkap ?? "User #${item.pelapor?.id ?? '-'}",
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 8),

          // ACTION BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol Hapus (Kiri)
              InkWell(
                onTap: () => _confirmDelete(context, provider, item),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: errorRed, size: 18),
                      const SizedBox(width: 4),
                      Text("Hapus", style: TextStyle(color: errorRed, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),

              // Tombol Aksi Kanan (Tergantung Status)
              if (item.status == 'proses_klaim')
                ElevatedButton.icon(
                  onPressed: () => _showBuktiDialog(context, item),
                  icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                  label: const Text("Selesaikan", style: TextStyle(color: Colors.white, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
              else if (item.status == 'open')
                const Text("Menunggu Klaim User", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic))
              else
                Row(
                  children: [
                    Icon(Icons.done_all, size: 16, color: successGreen),
                    const SizedBox(width: 4),
                    Text("Selesai", style: TextStyle(fontSize: 12, color: successGreen, fontWeight: FontWeight.bold)),
                  ],
                )
            ],
          )
        ],
      ),
    );
  }

  // --- ACTIONS ---

  void _confirmDelete(BuildContext context, BarangProvider provider, Barang item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Barang?"),
        content: Text("Anda yakin ingin menghapus '${item.namaBarang}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              bool success = await provider.deleteBarang(item.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Barang berhasil dihapus")));
              }
            },
            child: Text("Hapus", style: TextStyle(color: errorRed, fontWeight: FontWeight.bold)),
          ),
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
                Text("Validasi Pengambilan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: darkNavy)),
                const SizedBox(height: 8),
                const Text("Upload foto bukti serah terima barang kepada pemilik asli.", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                
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
                      ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.camera_alt, color: Colors.blue, size: 30),
                          Text("Ambil Foto Bukti", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))
                        ])
                      : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: "Catatan Admin (Opsional)",
                    filled: true, fillColor: bgPage,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: darkNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      if(imageFile == null) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto bukti wajib diisi!")));
                         return;
                      }
                      Navigator.pop(context);
                      
                      // Menggunakan KlaimProvider untuk upload bukti (sesuai context kode sebelumnya)
                      bool success = await Provider.of<KlaimProvider>(context, listen: false)
                          .uploadBukti(item.id, imageFile!, noteController.text);
                      
                      if(success && context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Barang ${item.namaBarang} diselesaikan!"), backgroundColor: successGreen));
                         // Refresh data
                         Provider.of<BarangProvider>(context, listen: false).fetchBarang(refresh: true);
                      }
                    }, 
                    child: const Text("Konfirmasi Selesai", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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