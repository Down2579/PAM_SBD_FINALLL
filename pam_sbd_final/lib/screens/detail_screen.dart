import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers.dart';
import 'user_claim_validation_page.dart';
import 'add_item_screen.dart'; 

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
      setState(() => _imageFile = File(picked.path));
    }
  }

  // --- LOGIC DELETE BARANG ---
  Future<void> _deleteItem(BuildContext context, int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Laporan?"),
        content: const Text("Laporan ini akan dihapus permanen. Tindakan ini tidak bisa dibatalkan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: Text("Hapus", style: TextStyle(color: errorRed, fontWeight: FontWeight.bold))
          ),
        ],
      )
    );

    if (confirm == true) {
      if(!mounted) return;
      
      final success = await Provider.of<BarangProvider>(context, listen: false).deleteBarang(id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan berhasil dihapus")));
        Navigator.pop(context, true); 
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menghapus laporan"), backgroundColor: errorRed));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).currentUser;
    final barangProvider = Provider.of<BarangProvider>(context);
    final klaimProvider = Provider.of<KlaimProvider>(context);
    
    final item = barangProvider.selectedBarang ?? widget.item;

    final bool isMyItem = currentUser != null && item.pelapor?.id == currentUser.id;
    final bool isPending = item.status == 'pending';
    
    final bool hasPendingClaimInList = klaimProvider.klaimList.any(
      (k) => k.statusKlaim == 'menunggu_verifikasi_pemilik'
    );

    final bool hasIncomingClaim = isMyItem && (
      (item.status == 'proses_klaim' && item.statusVerifikasi == 'menunggu_pemilik') ||
      hasPendingClaimInList
    );

    final bool hasAlreadyClaimed = klaimProvider.klaimList.any(
      (klaim) => klaim.idPenemu == currentUser?.id
    );

    final bool showClaimForm = !isMyItem && !hasAlreadyClaimed && item.status == 'open';

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
        // MENU TITIK TIGA DI ATAS (OPSIONAL)
        actions: (isMyItem && isPending) ? [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AddItemScreen(itemToEdit: item)))
                    .then((_) => barangProvider.getDetail(item.id));
              } else if (value == 'delete') {
                _deleteItem(context, item.id);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text("Edit")])),
              PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text("Hapus", style: TextStyle(color: Colors.red))])),
            ],
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
              child: const Icon(Icons.more_vert, color: Colors.black87),
            ),
          )
        ] : null,
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
                  // HEADER
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

                  // BADGE STATUS MENUNGGU
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

                  // DESKRIPSI
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

                  // ✅✅ FITUR BARU: TOMBOL EDIT & DELETE YANG BESAR ✅✅
                  if (isMyItem && isPending) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _deleteItem(context, item.id),
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            label: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        // ... tombol hapus (kode sebelumnya) ...
                        
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async { // ✅ Ubah jadi async
                              // 1. Tunggu hasil dari halaman Edit
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddItemScreen(itemToEdit: item)
                                ),
                              );

                              // 2. Jika result == true (berhasil simpan), refresh data
                              if (result == true && mounted) {
                                // Tampilkan loading sebentar (opsional, tapi bagus untuk UX)
                                // setState(() {}); 
                                
                                // Fetch data terbaru dari server
                                await barangProvider.getDetail(item.id);
                              }
                            },
                            icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.white),
                            label: const Text("Edit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pendingPurple,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ACTION SECTION LAINNYA
                  if (barangProvider.isLoading || klaimProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  
                  else if (isMyItem)
                    if (hasIncomingClaim)
                      _buildOwnerActionBox(context, item)
                    else 
                      _buildOwnerStatusBox(isPending)

                  else if (hasAlreadyClaimed)
                    _buildAlreadyClaimedBox()

                  else if (item.status != 'open')
                    if (item.status == 'selesai' && item.bukti.isNotEmpty)
                      _buildProofSection(item.bukti.first)
                    else
                      _buildClosedStatusBox(item.status)
                  
                  else if (showClaimForm)
                    _buildClaimSection(context, item),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS (Sama seperti sebelumnya) ---
Widget _buildOwnerActionBox(BuildContext context, Barang item) {
    // LOGIC PERBEDAAN TAMPILAN
    bool isMyItemLost = item.tipeLaporan == 'hilang';
    
    // Jika barang saya HILANG, berarti ada yang MENEMUKAN.
    // Jika barang saya TEMUAN, berarti ada yang MENGAKU PEMILIK.
    String title = isMyItemLost ? "Barang Anda Ditemukan!" : "Klaim Kepemilikan Masuk!";
    String desc = isMyItemLost 
        ? "Seseorang mengaku telah menemukan barang yang Anda laporkan hilang."
        : "Seseorang mengaku bahwa barang temuan Anda adalah miliknya.";

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
          Text(title, style: TextStyle(color: warningOrange, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text(desc, textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserClaimValidationPage()));
              },
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text("Lihat & Validasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: warningOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }

Widget _buildClaimSection(BuildContext context, Barang item) {
    // LOGIC PERBEDAAN TAMPILAN
    bool isItemLost = item.tipeLaporan == 'hilang';

    // Jika barang HILANG -> Saya menemukan -> Input "Lokasi Ditemukan"
    // Jika barang TEMUAN -> Itu milik saya -> Input "Perkiraan Lokasi Hilang"
    String title = isItemLost ? "Saya Menemukan Barang Ini" : "Ini Barang Milik Saya";
    String subtitle = isItemLost 
        ? "Bantu pemilik mendapatkan kembali barangnya dengan mengisi data di bawah."
        : "Buktikan kepemilikan Anda dengan menjelaskan detail barang.";
        
    String locationLabel = isItemLost ? "Lokasi Ditemukan" : "Perkiraan Lokasi Hilang";
    String locationHint = isItemLost ? "Cth: Di kantin, parkiran..." : "Cth: Terakhir saya bawa di...";
    
    String descLabel = isItemLost ? "Kondisi Barang Saat Ditemukan" : "Ciri-ciri Khusus (Bukti)";
    String descHint = isItemLost ? "Cth: Masih bagus, ada lecet..." : "Cth: Ada stiker nama, isi dompet...";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: textGrey, fontSize: 13)),
        const SizedBox(height: 20),
        
        TextField(
          controller: _lokasiController,
          decoration: InputDecoration(
            labelText: locationLabel,
            hintText: locationHint,
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
            labelText: descLabel,
            hintText: descHint,
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.description_outlined)
          ),
        ),
        const SizedBox(height: 16),
        
        // ... (Bagian Upload Foto dan Submit Button sama seperti sebelumnya) ...
        // Copy paste sisa widget dari kode sebelumnya
        GestureDetector(onTap: _pickImage, child: Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade400)), child: _imageFile == null ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, color: textGrey, size: 32), Text("Upload Foto", style: TextStyle(color: textGrey))]) : Image.file(_imageFile!, fit: BoxFit.cover))),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 54, child: ElevatedButton(onPressed: () => _submitClaim(context, item.id), style: ElevatedButton.styleFrom(backgroundColor: darkNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text("Kirim Klaim", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))))
      ],
    );
  }

  Future<void> _submitClaim(BuildContext context, int barangId) async {
    if (_pesanController.text.trim().isEmpty || _lokasiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lokasi dan Deskripsi wajib diisi!"))); return;
    }
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    final success = await Provider.of<KlaimProvider>(context, listen: false).ajukanKlaim({'id_barang': barangId.toString(), 'deskripsi_klaim': _pesanController.text, 'lokasi_ditemukan': _lokasiController.text}, _imageFile);
    if (!mounted) return; Navigator.pop(context);
    if (success) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Klaim berhasil diajukan!"), backgroundColor: successGreen)); Provider.of<KlaimProvider>(context, listen: false).loadKlaimByBarang(barangId); } 
    else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Gagal mengajukan klaim."), backgroundColor: errorRed)); }
  }

  Widget _buildProofSection(BuktiPengambilan bukti) {
    String? proofImageUrl = bukti.fotoBukti.isNotEmpty ? (bukti.fotoBukti.startsWith('http') ? bukti.fotoBukti : '$baseUrlImage${bukti.fotoBukti}') : null;
    return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: successGreen.withOpacity(0.3))), child: Column(children: [Text("Barang Telah Selesai", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkNavy)), if(proofImageUrl != null) Image.network(proofImageUrl, height: 150)]));
  }

  Widget _buildCategoryChip(String label) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: darkNavy.withOpacity(0.08), borderRadius: BorderRadius.circular(20)), child: Text(label.toUpperCase(), style: TextStyle(color: darkNavy, fontWeight: FontWeight.bold, fontSize: 11)));
  Widget _buildTypeBadge(Barang item) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: item.tipeLaporan == 'hilang' ? errorRed : successGreen, borderRadius: BorderRadius.circular(30)), child: Text(item.tipeLaporan == 'hilang' ? "KEHILANGAN" : "DITEMUKAN", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)));
  Widget _buildModernInfoTile({required IconData icon, required String title, required String value, required Color color}) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))]), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 11, color: textGrey)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]))]));
  Widget _buildOwnerStatusBox(bool isPending) => Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isPending ? pendingPurple.withOpacity(0.1) : const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16), border: Border.all(color: isPending ? pendingPurple.withOpacity(0.3) : const Color(0xFFDBEAFE))), child: Row(children: [Icon(isPending ? Icons.hourglass_top : Icons.verified_rounded, color: isPending ? pendingPurple : const Color(0xFF2563EB)), const SizedBox(width: 12), Expanded(child: Text(isPending ? "Laporan sedang menunggu verifikasi admin." : "Ini adalah laporan Anda. Belum ada klaim masuk.", style: TextStyle(color: isPending ? pendingPurple : const Color(0xFF1E40AF), fontWeight: FontWeight.w600, fontSize: 13)))]));
  Widget _buildAlreadyClaimedBox() => Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFBBF7D0))), child: Column(children: [const Icon(Icons.mark_email_read_rounded, color: Color(0xFF15803D), size: 40), const Text("Klaim Terkirim", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF15803D))), const Text("Mohon tunggu verifikasi.", style: TextStyle(fontSize: 13))]));
  Widget _buildClosedStatusBox(String status) => Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)), child: Column(children: [Icon(Icons.lock_rounded, color: textGrey, size: 30), Text("Barang ini sudah ${status == 'selesai' ? 'Selesai' : 'Diproses'}", style: TextStyle(color: textGrey, fontWeight: FontWeight.bold))]));
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImagePage({super.key, required this.imageUrl});
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, body: Stack(children: [Center(child: InteractiveViewer(child: Image.network(imageUrl))), Positioned(top: 40, left: 20, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)))]));
}