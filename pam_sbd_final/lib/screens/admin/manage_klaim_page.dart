import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Pastikan package intl sudah ada di pubspec.yaml
import '../../providers.dart';
import '../../models.dart';
import 'form_bukti_pengembalian_page.dart'; // Pastikan file ini ada di folder yang sama

class ManageKlaimPage extends StatefulWidget {
  const ManageKlaimPage({super.key});

  @override
  State<ManageKlaimPage> createState() => _ManageKlaimPageState();
}

class _ManageKlaimPageState extends State<ManageKlaimPage> {
  final Color darkNavy = const Color(0xFF2B4263);
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color successGreen = const Color(0xFF10B981);
  final Color errorRed = const Color(0xFFEF4444);
  
  // IP Emulator Android Default. Sesuaikan jika pakai device asli.
  final String baseUrlImage = 'http://10.0.2.2:8000'; 

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<KlaimProvider>(context, listen: false).fetchAllKlaim()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        title: const Text("Validasi Klaim", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: darkNavy,
        elevation: 0,
      ),
      body: Consumer<KlaimProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator(color: darkNavy));
          if (provider.klaimList.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            onRefresh: () => provider.fetchAllKlaim(),
            color: darkNavy,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.klaimList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildFullKlaimCard(provider.klaimList[index], provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Tidak ada klaim masuk", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildFullKlaimCard(KlaimPenemuan klaim, KlaimProvider provider) {
    final barang = klaim.barang;
    final penemu = klaim.penemu;
    final pelapor = barang?.pelapor; 

    // Logic status: tombol hanya aktif jika status masih menunggu
    bool isActionable = klaim.statusKlaim == 'menunggu_verifikasi_pemilik' || 
                        klaim.statusKlaim == 'menunggu_verifikasi_admin';

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: ID & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text("Klaim No ${klaim.id}", style: const TextStyle(fontSize: 12, color: Colors.white)),
                  backgroundColor: darkNavy,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                _buildStatusBadge(klaim.statusKlaim),
              ],
            ),
            const Divider(),

            // BAGIAN 1: DATA BARANG
            const Text("DATA BARANG", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageThumb(barang?.gambarUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(barang?.namaBarang ?? "Barang ID ${klaim.idBarang}", 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkNavy)),
                      Text("${barang?.kategori?.namaKategori ?? '-'} • ${barang?.lokasi?.namaLokasi ?? '-'}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text("Pelapor: ${pelapor?.namaLengkap ?? '-'}", style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
            
            const SizedBox(height: 16),

            // BAGIAN 2: DATA KLAIM
            const Text("DATA KLAIM PENEMUAN", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgPage, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_pin, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text("Penemu: ${penemu?.namaLengkap ?? 'User ${klaim.idPenemu}'}", 
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if (penemu?.nomorTelepon != null)
                     Padding(
                       padding: const EdgeInsets.only(left: 24, top: 2),
                       child: Text(penemu!.nomorTelepon!, style: const TextStyle(fontSize: 12, color: Colors.blue)),
                     ),
                  const SizedBox(height: 8),
                  
                  // FOTO PENEMUAN
                  if (klaim.fotoPenemuan != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          klaim.fotoPenemuan!.startsWith('http') ? klaim.fotoPenemuan! : baseUrlImage + klaim.fotoPenemuan!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                             Container(height: 50, color: Colors.grey[200], child: const Center(child: Text("Gagal muat foto penemuan"))),
                        ),
                      ),
                    ),

                  const SizedBox(height: 4),
                  const Text("Lokasi Ditemukan:", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(klaim.lokasiDitemukan, style: const TextStyle(fontWeight: FontWeight.w500)),
                  
                  const SizedBox(height: 4),
                  const Text("Alasan/Deskripsi:", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(klaim.deskripsiPenemuan ?? "-", style: const TextStyle(fontStyle: FontStyle.italic)),
                  
                  const SizedBox(height: 8),
                  Text(
                    "Diajukan: ${DateFormat('dd MMM yyyy, HH:mm').format(klaim.createdAt)}",
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // BUTTONS
            if (isActionable)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleReject(context, provider, klaim.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: errorRed,
                        side: BorderSide(color: errorRed),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Tolak"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigasi ke Halaman Bukti Pengembalian (Sesuai Request)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormBuktiPengembalianPage(klaim: klaim),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                      label: const Text("Terima", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text("Klaim telah diproses (${klaim.statusKlaim.replaceAll('_', ' ')})", 
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumb(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        width: 60, height: 60,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
        child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url.startsWith('http') ? url : baseUrlImage + url,
        width: 60, height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text = status.replaceAll('_', ' ').toUpperCase();
    
    switch (status) {
      case 'diterima_pemilik': 
      case 'selesai':
        color = successGreen; 
        break;
      case 'ditolak_admin': 
      case 'ditolak':
        color = errorRed; 
        break;
      default: 
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5))
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Future<void> _handleReject(BuildContext context, KlaimProvider provider, int id) async {
    bool? confirm = await showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text("Tolak Klaim?"),
        content: const Text("Apakah Anda yakin ingin menolak klaim ini? Status akan berubah menjadi Ditolak."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Tolak", style: TextStyle(color: Colors.red))),
        ],
      )
    );

    if (confirm == true) {
      bool success = await provider.updateStatus(id, 'ditolak_admin');
      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Klaim ditolak.")));
        provider.fetchAllKlaim();
      } else {
         if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal update status.")));
      }
    }
  }
}