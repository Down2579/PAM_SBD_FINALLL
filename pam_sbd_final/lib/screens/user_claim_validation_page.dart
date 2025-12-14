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
  // Warna Palette
  final Color darkNavy = const Color(0xFF2B4263);
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color successGreen = const Color(0xFF10B981);
  final Color errorRed = const Color(0xFFEF4444);
  final Color pendingOrange = const Color(0xFFF59E0B);
  
  final String baseUrlImage = 'http://10.0.2.2:8000'; 

  @override
  void initState() {
    super.initState();
    // Fetch klaim saat halaman dibuka
    // Pastikan di Provider logic fetchAllKlaim sudah menghandle filter 'user biasa' vs 'admin'
    // (Kode controller backend Anda sudah mendukung filter ini)
    Future.microtask(() => 
      Provider.of<KlaimProvider>(context, listen: false).fetchAllKlaim()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        title: const Text("Klaim Masuk", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<KlaimProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator(color: darkNavy));
          }
          
          // Filter Lokal: Pastikan hanya menampilkan klaim yang statusnya butuh aksi pemilik
          // Atau tampilkan semua history juga boleh.
          final List<KlaimPenemuan> myClaims = provider.klaimList;

          if (myClaims.isEmpty) {
            return _buildEmptyState();
          }

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
    final penemu = klaim.penemu; // Orang yang mengklaim barang kita

    // Cek apakah tombol aksi perlu dimunculkan
    // Hanya muncul jika status masih "menunggu_verifikasi_pemilik"
    bool showActions = klaim.statusKlaim == 'menunggu_verifikasi_pemilik';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER: INFO BARANG
            Row(
              children: [
                _buildImageThumb(barang?.gambarUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barang?.namaBarang ?? "Unknown Item", 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkNavy),
                      ),
                      Text(
                        "Diklaim pada: ${DateFormat('dd MMM yyyy').format(klaim.createdAt)}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(klaim.statusKlaim),
              ],
            ),
            const Divider(height: 24),
            
            // 2. INFO PENGKLAIM (PENEMU)
            Text("Pengaju Klaim:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
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
                        radius: 14,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, size: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        penemu?.namaLengkap ?? "User #${klaim.idPenemu}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text("Pesan / Ciri-ciri:", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(
                    klaim.deskripsiPenemuan ?? "-",
                    style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                  
                  // Tampilkan Foto Bukti jika ada
                  if (klaim.fotoPenemuan != null) ...[
                    const SizedBox(height: 12),
                    const Text("Bukti Foto:", style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        klaim.fotoPenemuan!.startsWith('http') 
                           ? klaim.fotoPenemuan! 
                           : baseUrlImage + klaim.fotoPenemuan!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => const Text("Gagal muat foto", style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. ACTION BUTTONS
            if (showActions)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleAction(context, provider, klaim.id, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: errorRed,
                        side: BorderSide(color: errorRed),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Tolak Klaim"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleAction(context, provider, klaim.id, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkNavy,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text("Terima Klaim", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            else
              // Jika sudah diproses, tampilkan info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!)
                ),
                child: const Text(
                  "Anda sudah memproses klaim ini.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildImageThumb(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        width: 50, height: 50,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
        child: Icon(Icons.image, color: Colors.grey[400]),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url.startsWith('http') ? url : baseUrlImage + url,
        width: 50, height: 50,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'diterima_pemilik':
        color = successGreen;
        text = "DITERIMA";
        break;
      case 'ditolak_pemilik':
        color = errorRed;
        text = "DITOLAK";
        break;
      case 'menunggu_verifikasi_pemilik':
        color = pendingOrange;
        text = "BUTUH AKSI";
        break;
      default:
        color = Colors.grey;
        text = status.toUpperCase().replaceAll('_', ' ');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  // --- LOGIC ACTIONS ---

  Future<void> _handleAction(BuildContext context, KlaimProvider provider, int id, bool isAccept) async {
    // 1. Konfirmasi Dialog
    bool? confirm = await showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: Text(isAccept ? "Terima Klaim?" : "Tolak Klaim?"),
        content: Text(isAccept 
            ? "Dengan menerima, Anda memverifikasi bahwa user ini adalah pemilik yang sah."
            : "Klaim akan ditolak dan barang akan kembali terbuka untuk klaim lain."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isAccept ? "Ya, Terima" : "Tolak", style: TextStyle(color: isAccept ? darkNavy : errorRed, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );

    if (confirm != true) return;

    // 2. Panggil API Provider
    // String status yang dikirim ke backend sesuai controller Anda
    String statusApi = isAccept ? 'diterima_pemilik' : 'ditolak_pemilik';
    
    bool success = await provider.updateStatus(id, statusApi);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAccept ? "Klaim diterima! Menunggu admin." : "Klaim berhasil ditolak."),
          backgroundColor: isAccept ? successGreen : errorRed,
        )
      );
      // Refresh list
      provider.fetchAllKlaim();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memproses klaim."), backgroundColor: Colors.red)
      );
    }
  }
}