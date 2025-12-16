import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers.dart';
import '../../models.dart';

class UserClaimValidationPage extends StatefulWidget {
  const UserClaimValidationPage({super.key});

  @override
  State<UserClaimValidationPage> createState() => _UserClaimValidationPageState();
}

class _UserClaimValidationPageState extends State<UserClaimValidationPage> {
  final Color darkNavy = const Color(0xFF2B4263);
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color successGreen = const Color(0xFF10B981);
  final Color errorRed = const Color(0xFFEF4444);
  final Color pendingOrange = const Color(0xFFF59E0B);
  
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
        title: const Text("Daftar Klaim Masuk", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: darkNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<KlaimProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator(color: darkNavy));
          
          final List<KlaimPenemuan> myClaims = provider.klaimList;

          if (myClaims.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            onRefresh: () => provider.fetchAllKlaim(),
            color: darkNavy,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: myClaims.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildClaimCard(context, myClaims[index], provider);
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
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Belum ada klaim masuk", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildClaimCard(BuildContext context, KlaimPenemuan klaim, KlaimProvider provider) {
    final barang = klaim.barang;
    final userClaimant = klaim.penemu; 

    // LOGIKA PERBEDAAN TAMPILAN (LOST vs FOUND)
    // Jika tipe laporan 'hilang', berarti saya kehilangan, orang ini MENEMUKANNYA.
    // Jika tipe laporan 'ditemukan', berarti saya menemukan, orang ini MENGAKU PEMILIKNYA.
    bool isMyItemLost = barang?.tipeLaporan == 'hilang';

    String labelUser = isMyItemLost ? "Ditemukan Oleh:" : "Diklaim Oleh (Mengaku Pemilik):";
    String labelLocation = isMyItemLost ? "Lokasi Ditemukan:" : "Perkiraan Lokasi Hilang:";
    String labelDesc = isMyItemLost ? "Kondisi Barang:" : "Ciri-ciri Khusus (Bukti):";
    
    // Tombol Aksi
    bool showActions = klaim.statusKlaim == 'menunggu_verifikasi_pemilik';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER BARANG
            Row(
              children: [
                _buildImageThumb(barang?.gambarUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barang?.namaBarang ?? "-", 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkNavy),
                      ),
                      Text(
                        "Status: ${isMyItemLost ? 'HILANG' : 'DITEMUKAN'}",
                        style: TextStyle(fontSize: 12, color: isMyItemLost ? errorRed : successGreen, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(klaim.statusKlaim),
              ],
            ),
            const Divider(height: 24),
            
            // INFO USER YANG MENGKLAIM
            Text(labelUser, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgPage, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userClaimant?.namaLengkap ?? "User #${klaim.idPenemu}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          if (userClaimant?.nomorTelepon != null)
                            Text(userClaimant!.nomorTelepon!, style: TextStyle(fontSize: 11, color: darkNavy)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Detail Klaim
                  _buildDetailRow(Icons.pin_drop_outlined, labelLocation, klaim.lokasiDitemukan),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.description_outlined, labelDesc, klaim.deskripsiPenemuan ?? "-"),

                  // Foto Bukti
                  if (klaim.fotoPenemuan != null) ...[
                    const SizedBox(height: 12),
                    const Text("Bukti Foto:", style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        klaim.fotoPenemuan!.startsWith('http') ? klaim.fotoPenemuan! : baseUrlImage + klaim.fotoPenemuan!,
                        height: 120, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => const Text("Gagal muat foto", style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BUTTONS
            if (showActions)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleAction(context, provider, klaim.id, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: errorRed,
                        side: BorderSide(color: errorRed),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Tolak"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleAction(context, provider, klaim.id, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Konfirmasi Benar", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                child: const Text("Sudah Diproses", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumb(String? url) {
    if (url == null || url.isEmpty) {
      return Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.image));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(url.startsWith('http') ? url : baseUrlImage + url, width: 50, height: 50, fit: BoxFit.cover),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'diterima_pemilik' ? successGreen : (status == 'ditolak_pemilik' ? errorRed : pendingOrange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status.replaceAll('_', ' ').toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Future<void> _handleAction(BuildContext context, KlaimProvider provider, int id, bool isAccept) async {
    bool? confirm = await showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: Text(isAccept ? "Konfirmasi Klaim?" : "Tolak Klaim?"),
        content: Text(isAccept 
            ? "Apakah Anda yakin data ini VALID? Status akan berubah dan menunggu admin menyelesaikan."
            : "Klaim akan ditolak."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Ya", style: TextStyle(color: isAccept ? darkNavy : errorRed, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );

    if (confirm != true) return;
    String statusApi = isAccept ? 'diterima_pemilik' : 'ditolak_pemilik';
    bool success = await provider.updateStatus(id, statusApi);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Berhasil diproses"), backgroundColor: successGreen));
      provider.fetchAllKlaim();
    }
  }
}