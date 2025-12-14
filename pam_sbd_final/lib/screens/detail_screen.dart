import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers.dart';
import 'user_claim_validation_page.dart';

class DetailScreen extends StatefulWidget {
  final Barang item;
  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _pesanController = TextEditingController();
  final _lokasiController = TextEditingController(); 
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // --- COLORS PALETTE ---
  final Color bgPage = const Color(0xFFF8FAFC);
  final Color darkNavy = const Color(0xFF2B4263);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);
  final Color successGreen = const Color(0xFF10B981);
  final Color warningOrange = const Color(0xFFF59E0B);
  final Color errorRed = const Color(0xFFEF4444);
  final Color pendingPurple = const Color(0xFF8B5CF6);

  final String baseUrlImage = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Load detail terbaru dan daftar klaim
      Provider.of<BarangProvider>(context, listen: false).getDetail(widget.item.id);
      Provider.of<KlaimProvider>(context, listen: false).loadKlaimByBarang(widget.item.id);
    });
  }

  @override
  void dispose() {
    _pesanController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).currentUser;
    final barangProvider = Provider.of<BarangProvider>(context);
    final klaimProvider = Provider.of<KlaimProvider>(context);
    
    // Gunakan data terbaru dari provider (jika null pakai widget.item)
    // PENTING: Jika barangProvider.selectedBarang masih null (loading), data UI mungkin belum update statusnya
    final item = barangProvider.selectedBarang ?? widget.item;

    // --- LOGIC PENGECEKAN STATUS (UPDATED) ---
    
    // 1. Apakah saya pemilik barang?
    final bool isMyItem = currentUser != null && item.pelapor?.id == currentUser.id;
    
    // 2. Cek List Klaim Langsung (Lebih Akurat daripada cek status barang)
    // Apakah ada klaim di list yang statusnya 'menunggu_verifikasi_pemilik'?
    final bool hasPendingClaimInList = klaimProvider.klaimList.any(
      (k) => k.statusKlaim == 'menunggu_verifikasi_pemilik'
    );

    // LOGIC KUNCI: 
    // Jika Saya Pemilik DAN (Status barang proses klaim ATAU Ada klaim pending di list)
    final bool hasIncomingClaim = isMyItem && (
      (item.status == 'proses_klaim' && item.statusVerifikasi == 'menunggu_pemilik') ||
      hasPendingClaimInList
    );

    final bool isPending = item.status == 'pending';

    final bool hasAlreadyClaimed = klaimProvider.klaimList.any(
      (klaim) => klaim.idPenemu == currentUser?.id
    );

    final bool showClaimForm = !isMyItem && !hasAlreadyClaimed && item.status == 'open';

    // Image URL Handler
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
            // IMAGE HEADER
            GestureDetector(
              onTap: () {
                if (fullImageUrl != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FullScreenImagePage(imageUrl: fullImageUrl!)));
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
                      : null,
                ),
              ),
            ),

            // CONTENT CONTAINER
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
                  // HEADER INFO
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
                      _buildTypeBadge(item),
                    ],
                  ),

                  // Pending Badge
                  if (isPending) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: pendingPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.hourglass_top_rounded, size: 14, color: pendingPurple),
                          const SizedBox(width: 6),
                          Text("Menunggu Verifikasi Admin", style: TextStyle(color: pendingPurple, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ],

                  const SizedBox(height: 24),

                  // INFO TILES
                  _buildModernInfoTile(
                    icon: Icons.location_on_rounded,
                    title: "Lokasi",
                    value: item.lokasi?.namaLokasi ?? "Tidak diketahui",
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 12),
                  _buildModernInfoTile(
                    icon: Icons.person_rounded,
                    title: "Pelapor",
                    value: item.pelapor?.namaLengkap ?? "Anonymous",
                    color: warningOrange,
                  ),

                  const SizedBox(height: 24),
                  Text("Deskripsi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
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
                      item.deskripsi.isNotEmpty ? item.deskripsi : "-",
                      style: TextStyle(color: textDark.withOpacity(0.8), height: 1.6, fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ================= ACTION SECTION =================
                  if (barangProvider.isLoading || klaimProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  
                  // 1. BARANG MILIK SENDIRI
                  else if (isMyItem)
                    // Cek Variable Baru: hasIncomingClaim
                    if (hasIncomingClaim)
                      _buildOwnerActionBox(context) // TAMPILKAN TOMBOL VALIDASI
                    else
                      _buildOwnerStatusBox(isPending)

                  // 2. USER SUDAH PERNAH KLAIM
                  else if (hasAlreadyClaimed)
                    _buildAlreadyClaimedBox()

                  // 3. BARANG CLOSED
                  else if (item.status != 'open')
                    _buildClosedStatusBox(item.status)
                  
                  // 4. FORM KLAIM
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

  // --- 1. BOX KHUSUS OWNER: ADA KLAIM MASUK ---
  Widget _buildOwnerActionBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: warningOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warningOrange.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.notifications_active_outlined, color: warningOrange, size: 40),
          const SizedBox(height: 12),
          Text(
            "Ada Klaim Masuk!",
            style: TextStyle(color: warningOrange, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            "Seseorang mengajukan klaim atas barang ini. Silakan periksa bukti yang mereka lampirkan.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigasi ke Halaman Validasi
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserClaimValidationPage())
                );
              },
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text("Lihat & Verifikasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: warningOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- Widget Helper Lainnya (Copy paste dari sebelumnya) ---
  Widget _buildClaimSection(BuildContext context, int barangId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Text("Ajukan Klaim", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
        const SizedBox(height: 4),
        Text("Lengkapi formulir di bawah ini sebagai bukti valid.", style: TextStyle(color: textGrey, fontSize: 13)),
        const SizedBox(height: 20),
        
        TextField(
          controller: _lokasiController,
          decoration: InputDecoration(
            labelText: "Lokasi Ditemukan",
            hintText: "Cth: Di kantin meja nomor 5",
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.pin_drop_outlined)
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _pesanController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: "Deskripsi / Ciri Khusus",
            hintText: "Cth: Ada gantungan kunci beruang...",
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.description_outlined)
          ),
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150, width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
              image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null
            ),
            child: _imageFile == null 
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, color: textGrey, size: 32), const SizedBox(height: 8), Text("Upload Foto Bukti (Opsional)", style: TextStyle(color: textGrey, fontWeight: FontWeight.w600))])
              : null,
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton(
            onPressed: () => _submitClaim(context, barangId),
            style: ElevatedButton.styleFrom(backgroundColor: darkNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4),
            child: const Text("Kirim Klaim", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        )
      ],
    );
  }

  Future<void> _submitClaim(BuildContext context, int barangId) async {
    if (_pesanController.text.trim().isEmpty || _lokasiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lokasi dan Deskripsi wajib diisi!")));
      return;
    }
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    final success = await Provider.of<KlaimProvider>(context, listen: false).ajukanKlaim(
      {'id_barang': barangId.toString(), 'deskripsi_klaim': _pesanController.text, 'lokasi_ditemukan': _lokasiController.text}, 
      _imageFile
    );
    if (!mounted) return;
    Navigator.pop(context); 
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Klaim berhasil diajukan!"), backgroundColor: successGreen));
      Provider.of<KlaimProvider>(context, listen: false).loadKlaimByBarang(barangId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Gagal mengajukan klaim."), backgroundColor: errorRed));
    }
  }

  Widget _buildCategoryChip(String label) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: darkNavy.withOpacity(0.08), borderRadius: BorderRadius.circular(20)), child: Text(label.toUpperCase(), style: TextStyle(color: darkNavy, fontWeight: FontWeight.bold, fontSize: 11)));
  }

  Widget _buildTypeBadge(Barang item) {
    bool isLost = item.tipeLaporan == 'hilang';
    return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: isLost ? errorRed : successGreen, borderRadius: BorderRadius.circular(30)), child: Text(isLost ? "HILANG" : "DITEMUKAN", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)));
  }

  Widget _buildModernInfoTile({required IconData icon, required String title, required String value, required Color color}) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))]), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 11, color: textGrey)), const SizedBox(height: 2), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]))]));
  }

  Widget _buildOwnerStatusBox(bool isPending) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isPending ? pendingPurple.withOpacity(0.1) : const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16), border: Border.all(color: isPending ? pendingPurple.withOpacity(0.3) : const Color(0xFFDBEAFE))),
      child: Row(children: [Icon(isPending ? Icons.hourglass_top : Icons.verified_rounded, color: isPending ? pendingPurple : const Color(0xFF2563EB)), const SizedBox(width: 12), Expanded(child: Text(isPending ? "Laporan sedang diverifikasi admin." : "Ini adalah laporan Anda. Belum ada klaim masuk.", style: TextStyle(color: isPending ? pendingPurple : const Color(0xFF1E40AF), fontWeight: FontWeight.w600, fontSize: 13)))]),
    );
  }

  Widget _buildAlreadyClaimedBox() {
    return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFBBF7D0))), child: Column(children: [const Icon(Icons.mark_email_read_rounded, color: Color(0xFF15803D), size: 40), const SizedBox(height: 12), const Text("Klaim Terkirim", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF15803D))), const Text("Mohon tunggu verifikasi.", style: TextStyle(fontSize: 13))]));
  }

  Widget _buildClosedStatusBox(String status) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)), child: Column(children: [Icon(Icons.lock_rounded, color: textGrey, size: 30), Text("Barang ini sudah ${status == 'selesai' ? 'Selesai' : 'Diproses'}", style: TextStyle(color: textGrey, fontWeight: FontWeight.bold))]));
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImagePage({super.key, required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: Stack(children: [Center(child: InteractiveViewer(child: Image.network(imageUrl))), Positioned(top: 40, left: 20, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)))]));
  }
}