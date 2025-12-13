import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers.dart';

class DetailScreen extends StatefulWidget {
  final Barang item;
  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _pesanController = TextEditingController();

  // ================= COLORS PALETTE =================
  final Color bgPage = const Color(0xFFF8FAFC);
  final Color darkNavy = const Color(0xFF2B4263);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);
  final Color successGreen = const Color(0xFF10B981);
  final Color warningOrange = const Color(0xFFF59E0B);
  final Color errorRed = const Color(0xFFEF4444);
  final Color infoBlue = const Color(0xFF3B82F6);

  final String baseUrlImage = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // 1. Ambil detail barang terbaru
      Provider.of<BarangProvider>(context, listen: false).getDetail(widget.item.id);
      
      // 2. Ambil daftar klaim untuk barang ini (Untuk cek apakah user sudah klaim)
      Provider.of<KlaimProvider>(context, listen: false).loadKlaimByBarang(widget.item.id);
    });
  }

  @override
  void dispose() {
    _pesanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).currentUser;
    final barangProvider = Provider.of<BarangProvider>(context);
    final klaimProvider = Provider.of<KlaimProvider>(context); // Listen perubahan klaim
    
    // Data Barang
    final item = barangProvider.selectedBarang ?? widget.item;

    // --- LOGIC PENGECEKAN ---
    
    // 1. Apakah ini barang milik sendiri?
    final bool isMyItem = currentUser != null && item.pelapor?.id == currentUser.id;

    // 2. Apakah user SUDAH PERNAH mengklaim barang ini?
    // Kita cek list klaim yang didapat dari provider, apakah ada id_penemu == id_user_login
    final bool hasAlreadyClaimed = klaimProvider.klaimList.any(
      (klaim) => klaim.idPenemu == currentUser?.id
    );

    // 3. Apakah form klaim boleh muncul? (Status open, bukan barang sendiri, dan BELUM klaim)
    final bool showClaimForm = !isMyItem && !hasAlreadyClaimed && item.status == 'open';

    // Handle Image URL
    String? fullImageUrl;
    if (item.gambarUrl != null && item.gambarUrl!.isNotEmpty) {
      fullImageUrl = item.gambarUrl!.startsWith('http')
          ? item.gambarUrl
          : '$baseUrlImage${item.gambarUrl}';
    }

    return Scaffold(
      backgroundColor: bgPage,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // 1. IMAGE HEADER
            GestureDetector(
              onTap: () {
                if (fullImageUrl != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImagePage(imageUrl: fullImageUrl!),
                    ),
                  );
                }
              },
              child: Hero(
                tag: "item_${item.id}",
                child: Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: darkNavy,
                    image: fullImageUrl != null
                        ? DecorationImage(image: NetworkImage(fullImageUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: fullImageUrl == null
                      ? const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 60))
                      : Stack(
                          children: [
                            Positioned(
                              bottom: 16, right: 16,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                child: const Icon(Icons.zoom_out_map, color: Colors.white, size: 20),
                              ),
                            )
                          ],
                        ),
                ),
              ),
            ),

            // 2. CONTENT CONTAINER
            Container(
              transform: Matrix4.translationValues(0, -30, 0),
              decoration: BoxDecoration(
                color: bgPage,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE & DATE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryChip(item.kategori?.namaKategori ?? "Umum"),
                      Text(
                        item.createdAt != null
                            ? DateFormat('dd MMM yyyy').format(item.createdAt)
                            : "-",
                        style: TextStyle(color: textGrey, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.namaBarang,
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textDark, height: 1.2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildStatusBadge(item),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // INFO TILES
                  _buildModernInfoTile(
                    icon: Icons.location_on_rounded,
                    title: "Location",
                    value: item.lokasi?.namaLokasi ?? "Lokasi tidak diketahui",
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 12),
                  _buildModernInfoTile(
                    icon: Icons.person_rounded,
                    title: "Reported by",
                    value: item.pelapor?.namaLengkap ?? "Anonymous",
                    color: warningOrange,
                  ),

                  const SizedBox(height: 24),

                  // DESCRIPTION
                  Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      item.deskripsi.isNotEmpty ? item.deskripsi : "Tidak ada deskripsi tambahan.",
                      style: TextStyle(color: textDark.withOpacity(0.8), height: 1.6, fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- ACTION SECTION ---
                  if (barangProvider.isLoading || klaimProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  
                  // A. Tampilan Pemilik Barang
                  else if (isMyItem)
                    _buildOwnerStatusBox()
                  
                  // B. Tampilan SUDAH PERNAH KLAIM (Logic Baru)
                  else if (hasAlreadyClaimed)
                    _buildAlreadyClaimedBox()

                  // C. Tampilan Barang Closed/Proses tapi bukan oleh kita
                  else if (item.status != 'open')
                    _buildClosedStatusBox(item.status)
                  
                  // D. Form Klaim (Masih Open & Belum Klaim)
                  else if (showClaimForm)
                    _buildClaimSection(context, item.id),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LOGIC & WIDGETS =================

  // Widget baru: Jika user sudah klaim
  Widget _buildAlreadyClaimedBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Light Green
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.mark_email_read_rounded, color: Color(0xFF15803D), size: 40),
          const SizedBox(height: 12),
          const Text(
            "Claim Submitted",
            style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            "Anda sudah mengajukan klaim untuk barang ini. Mohon tunggu verifikasi dari pemilik barang atau admin.",
            textAlign: TextAlign.center,
            style: TextStyle(color: const Color(0xFF15803D).withOpacity(0.8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ... (Sisa Widget dan Fungsi submitClaim sama seperti sebelumnya) ...
  
  Widget _buildClaimSection(BuildContext context, int barangId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Text("Is this yours?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
        const SizedBox(height: 4),
        Text("Describe details to prove ownership.", style: TextStyle(color: textGrey, fontSize: 13)),
        const SizedBox(height: 16),
        
        TextField(
          controller: _pesanController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Contoh: Di dalamnya ada KTP atas nama Budi...",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: darkNavy)),
          ),
        ),
        
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => _submitClaim(context, barangId),
            style: ElevatedButton.styleFrom(
              backgroundColor: darkNavy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: darkNavy.withOpacity(0.4),
            ),
            child: const Text("Submit Claim", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        )
      ],
    );
  }

  Future<void> _submitClaim(BuildContext context, int barangId) async {
    if (_pesanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Description cannot be empty")));
      return;
    }

    final success = await Provider.of<KlaimProvider>(context, listen: false).ajukanKlaim(
      {'id_barang': barangId.toString(), 'deskripsi_klaim': _pesanController.text}, 
      null
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Klaim berhasil diajukan!"), backgroundColor: successGreen)
      );
      // Refresh data klaim agar tampilan berubah menjadi "Already Claimed"
      Provider.of<KlaimProvider>(context, listen: false).loadKlaimByBarang(barangId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Gagal! Mungkin Anda sudah klaim sebelumnya."), backgroundColor: errorRed)
      );
    }
  }

  Widget _buildCategoryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: darkNavy.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: darkNavy, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildStatusBadge(Barang item) {
    bool isLost = item.tipeLaporan == 'hilang';
    Color color = isLost ? errorRed : successGreen;
    String text = isLost ? "LOST" : "FOUND";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildModernInfoTile({required IconData icon, required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 11, color: textGrey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, color: textDark, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOwnerStatusBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: Color(0xFF2563EB)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "This is your item. You can track the status in 'My Task'.",
              style: TextStyle(color: Color(0xFF1E40AF), fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosedStatusBox(String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_rounded, color: textGrey, size: 30),
          const SizedBox(height: 8),
          Text(
            "This item is ${status == 'selesai' ? 'Closed' : 'Under Process'}",
            style: TextStyle(color: textGrey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ================= HALAMAN FULL SCREEN IMAGE =================
class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(tag: imageUrl, child: Image.network(imageUrl)),
            ),
          ),
          Positioned(
            top: 40, left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}