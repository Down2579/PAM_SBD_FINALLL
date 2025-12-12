import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers.dart'; // Sesuaikan path

class DetailScreen extends StatefulWidget {
  final Barang item; // Menerima object Barang dari list sebelumnya (untuk preview awal)
  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _pesanController = TextEditingController();

  // Colors Palette
  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGrey = const Color(0xFF9CA3AF);
  final Color bgPage = const Color(0xFFF5F7FA);
  final Color successGreen = const Color(0xFF10B981);
  final Color errorRed = const Color(0xFFEF4444);
  final Color warningOrange = const Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    // Fetch detail lengkap dari server (untuk dapat data User Pelapor yg up-to-date)
    Future.microtask(() => 
      Provider.of<BarangProvider>(context, listen: false).getDetail(widget.item.id)
    );
  }

  @override
  void dispose() {
    _pesanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil user yang sedang login
    final currentUser = Provider.of<AuthProvider>(context).currentUser;
    
    // Ambil state detail barang dari provider
    // Jika sedang loading/null, pakai data widget.item sebagai placeholder
    final barangProvider = Provider.of<BarangProvider>(context);
    final itemDetail = barangProvider.selectedBarang ?? widget.item;

    // Logic Cek Pemilik
    final bool isMyItem = currentUser != null && itemDetail.pelapor?.id == currentUser.id;
    // Logic Bisa Klaim: Barang 'hilang' (bukan ditemukan), status 'open', dan bukan punya sendiri
    final bool canClaim = !isMyItem 
        && itemDetail.status == 'open' 
        && itemDetail.tipeLaporan == 'hilang'; 
        // Logic tambahan: Jika tipe 'ditemukan', user juga bisa klaim "Itu barang saya"
        // Sesuaikan dengan logic bisnis Anda. Di sini saya asumsikan dua arah bisa diklaim.
    
    // Logic umum: Orang lain bisa mengklaim barang yang statusnya masih open
    final bool showClaimForm = !isMyItem && itemDetail.status == 'open';

    return Scaffold(
      backgroundColor: bgPage,
      body: CustomScrollView(
        slivers: [
          // ================= SLIVER APP BAR (IMAGE) =================
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: darkNavy,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  itemDetail.gambarUrl != null
                      ? Image.network(
                          itemDetail.gambarUrl!, // Pastikan model getter URL lengkap
                          fit: BoxFit.cover,
                          errorBuilder: (_,__,___) => Container(color: Colors.grey),
                        )
                      : Container(
                          color: darkNavy,
                          child: Icon(
                            itemDetail.tipeLaporan == 'hilang' ? Icons.search_off : Icons.inventory_2,
                            size: 80, color: Colors.white.withOpacity(0.5)
                          ),
                        ),
                  // Gradient Overlay bawah agar text terbaca
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= CONTENT BODY =================
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: bgPage,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              transform: Matrix4.translationValues(0, -20, 0), // Overlap sedikit ke atas
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Title & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          itemDetail.namaBarang,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
                        ),
                      ),
                      _buildStatusBadge(itemDetail),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  // 2. Info Cards (Grid 2x2)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildInfoCard(Icons.category_outlined, "Category", itemDetail.kategori?.namaKategori ?? "-"),
                      _buildInfoCard(Icons.location_on_outlined, "Location", itemDetail.lokasi?.namaLokasi ?? "-"),
                      _buildInfoCard(Icons.calendar_today_outlined, "Date", 
                         itemDetail.tanggalKejadian != null 
                         ? DateFormat('dd MMM yyyy').format(itemDetail.tanggalKejadian!) 
                         : "-"
                      ),
                      _buildInfoCard(Icons.person_outline_rounded, "Posted By", itemDetail.pelapor?.namaLengkap ?? "Anonymous"),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 3. Description
                  Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]
                    ),
                    child: Text(
                      itemDetail.deskripsi,
                      style: TextStyle(fontSize: 14, color: textDark, height: 1.5),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 4. ACTION SECTION (Claim / Owner View)
                  if (barangProvider.isLoading)
                     const Center(child: CircularProgressIndicator())
                  else if (isMyItem)
                    _buildOwnerView()
                  else if (showClaimForm)
                    _buildClaimForm(context, itemDetail.id)
                  else
                    _buildClosedView(itemDetail.status),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SUB-WIDGETS =================

  Widget _buildStatusBadge(Barang item) {
    bool isLost = item.tipeLaporan == 'hilang';
    Color color = isLost ? errorRed : successGreen;
    if (item.status != 'open') color = warningOrange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            isLost ? "LOST" : "FOUND",
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(
            item.status.toUpperCase(),
            style: TextStyle(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgPage, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: darkNavy),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: textGrey)),
                Text(
                  value, 
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_rounded, color: accentBlue, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your Report", style: TextStyle(fontWeight: FontWeight.bold, color: accentBlue, fontSize: 16)),
                const SizedBox(height: 4),
                Text("This is the item you reported.", style: TextStyle(color: textDark, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosedView(String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline_rounded, color: textGrey, size: 40),
          const SizedBox(height: 8),
          Text(
            "This item is ${status == 'selesai' ? 'Closed' : 'Under Process'}",
            style: TextStyle(color: textGrey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimForm(BuildContext context, int barangId) {
    final klaimProvider = Provider.of<KlaimProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Claim This Item", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
        const SizedBox(height: 8),
        Text("If this item belongs to you (or you found it), please describe it to verify.", style: TextStyle(color: textGrey, fontSize: 13)),
        const SizedBox(height: 16),
        
        TextField(
          controller: _pesanController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Describe unique features (scratches, stickers, contents inside)...",
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: klaimProvider.isLoading ? null : () => _handleClaim(context, barangId),
            style: ElevatedButton.styleFrom(
              backgroundColor: successGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: klaimProvider.isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Submit Claim Request", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Future<void> _handleClaim(BuildContext context, int barangId) async {
    if (_pesanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a description")));
      return;
    }

    // Panggil Provider Klaim
    final success = await Provider.of<KlaimProvider>(context, listen: false).ajukanKlaim(
      {
        'id_barang': barangId.toString(),
        'deskripsi_klaim': _pesanController.text,
      }, 
      null // Foto identitas opsional, bisa ditambahkan UI nya jika perlu
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Claim submitted! Waiting for owner verification."), backgroundColor: successGreen)
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit claim. You might have already claimed this."), backgroundColor: errorRed)
      );
    }
  }
}