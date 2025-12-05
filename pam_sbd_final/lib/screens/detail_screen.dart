import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../providers.dart';
import '../api_service.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  final Item item;
  const DetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _pesanController = TextEditingController();
  bool _isLoadingClaim = false;

  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);
  final Color textSecondary = const Color(0xFF6B7280);
  final Color bgGrey = const Color(0xFFF5F7FA);
  final Color successGreen = const Color(0xFF10B981);
  final Color errorRed = const Color(0xFFEF4444);

  @override
  void dispose() {
    _pesanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final bool isMyItem = user != null && user.id == widget.item.idPelapor;
    final bool canClaim = !isMyItem && widget.item.status == 'open' && widget.item.tipeLaporan == 'hilang';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Detail Item",
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgGrey,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Icon(Icons.image_outlined, size: 100, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),

            // Header Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.namaBarang,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: widget.item.tipeLaporan.toLowerCase() == 'hilang'
                                  ? errorRed.withOpacity(0.2)
                                  : successGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.item.tipeLaporan.toLowerCase() == 'hilang' ? 'LOST' : 'FOUND',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: widget.item.tipeLaporan.toLowerCase() == 'hilang' ? errorRed : successGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: widget.item.status == 'open' ? successGreen.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.item.status == 'open' ? 'OPEN' : widget.item.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: widget.item.status == 'open' ? successGreen : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Detail Section
            Text(
              "Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 16),

            _buildDetailRow(Icons.widgets_outlined, "Category", widget.item.kategori ?? "-"),
            _buildDetailRow(Icons.location_on_outlined, "Location", widget.item.lokasi ?? "-"),
            _buildDetailRow(
              Icons.calendar_today_outlined,
              "Date",
              DateFormat('dd MMM yyyy').format(widget.item.tanggalKejadian),
            ),
            _buildDetailRow(Icons.person_outline, "Reported by", widget.item.pelaporNama ?? "-"),

            const SizedBox(height: 28),

            // Description
            Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1.5),
              ),
              child: Text(
                widget.item.deskripsi ?? "No description",
                style: TextStyle(fontSize: 14, color: textDark, height: 1.6),
              ),
            ),

            const SizedBox(height: 28),

            // Claim Section
            if (isMyItem)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentBlue, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: accentBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "This is your report",
                        style: TextStyle(color: accentBlue, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            if (canClaim) ...[
              const SizedBox(height: 28),
              Text(
                "Claim This Item",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pesanController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Describe identifying features (color, marks, etc.)",
                  hintStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: darkNavy, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoadingClaim ? null : _handleClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successGreen,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  icon: _isLoadingClaim
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle, color: Colors.white),
                  label: Text(
                    _isLoadingClaim ? "Submitting..." : "Submit Claim",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: darkNavy),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleClaim() async {
    if (_pesanController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please describe the item"),
          backgroundColor: errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoadingClaim = true);

    try {
      String res = await ApiService().claimItem(widget.item.id, _pesanController.text);
      if (!mounted) return;

      if (res.contains("Berhasil") || res.contains("success")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Claim submitted successfully!"),
            backgroundColor: successGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res),
            backgroundColor: errorRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoadingClaim = false);
    }
  }
}