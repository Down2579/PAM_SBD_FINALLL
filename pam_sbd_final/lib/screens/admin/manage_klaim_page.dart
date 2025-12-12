import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../models.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<KlaimProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) return Center(child: CircularProgressIndicator(color: darkNavy));
                  if (provider.klaimList.isEmpty) return _buildEmptyState();

                  return RefreshIndicator(
                    onRefresh: () => provider.fetchAllKlaim(),
                    color: darkNavy,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: provider.klaimList.length,
                      itemBuilder: (context, index) {
                        return _buildKlaimCard(provider.klaimList[index], provider);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: bgPage,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Incoming Claims", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkNavy)),
          Text("Validasi permintaan klaim barang", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Tidak ada data klaim", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildKlaimCard(KlaimPenemuan klaim, KlaimProvider provider) {
    bool isPending = klaim.statusKlaim == 'menunggu_verifikasi_pemilik' || klaim.statusKlaim == 'menunggu_verifikasi_admin'; // Sesuaikan enum db
    // Jika backend menggunakan status lain, sesuaikan logic ini

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: darkNavy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("#${klaim.id}", style: TextStyle(fontWeight: FontWeight.bold, color: darkNavy, fontSize: 12)),
              ),
              const Spacer(),
              _buildStatusBadge(klaim.statusKlaim),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.inventory_2_outlined, size: 20, color: Colors.grey[400]),
              const SizedBox(width: 10),
              // Nama barang (Perlu relasi di model, jika null tampilkan ID)
              Expanded(
                child: Text(
                   "Barang ID: ${klaim.idBarang}", // Idealnya: klaim.barang?.namaBarang
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline, size: 20, color: Colors.grey[400]),
              const SizedBox(width: 10),
              Text(klaim.penemu?.namaLengkap ?? "User ID: ${klaim.idPenemu}", style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgPage, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Alasan Klaim:", style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(klaim.deskripsiPenemuan ?? "-", style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleAction(context, provider, klaim.id, 'ditolak_admin'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: errorRed,
                    side: BorderSide(color: errorRed.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text("Tolak"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleAction(context, provider, klaim.id, 'diterima_pemilik'), // Atau divalidasi_admin
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text("Terima", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'diterima_pemilik': color = successGreen; break;
      case 'ditolak_admin': color = errorRed; break;
      default: color = Colors.orange;
    }
    return Text(
      status.replaceAll('_', ' ').toUpperCase(),
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
    );
  }

  Future<void> _handleAction(BuildContext context, KlaimProvider provider, int id, String status) async {
    bool success = await provider.updateStatus(id, status);
    if(success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Status berhasil diubah ke $status")));
      provider.fetchAllKlaim(); // Refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengubah status"), backgroundColor: Colors.red));
    }
  }
}