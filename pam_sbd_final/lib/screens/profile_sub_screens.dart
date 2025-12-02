import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart';
import '../api_service.dart';
import '../models.dart';
import 'detail_screen.dart'; // Untuk Riwayat

// Warna Tema
const Color darkBlue = Color(0xFF2B4263);
const Color textDark = Color(0xFF1F1F1F);
const Color bgGrey = Color(0xFFF5F5F5);

// ================= 1. HALAMAN EDIT PROFILE =================
class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.namaLengkap ?? "");
    _phoneController = TextEditingController(text: user?.nomorTelepon ?? "");
    _emailController = TextEditingController(text: user?.email ?? "");
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit Profile", style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput("Nama Lengkap", _nameController, Icons.person),
              SizedBox(height: 20),
              _buildInput("Email", _emailController, Icons.email),
              SizedBox(height: 20),
              _buildInput("Nomor HP", _phoneController, Icons.phone),
              SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      bool success = await auth.updateProfile(
                        _nameController.text,
                        _phoneController.text,
                        _emailController.text
                      );

                      if (success) {
                        Navigator.pop(context, true); // Kembali & beri sinyal sukses
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profil berhasil diperbarui")));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memperbarui profil")));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: auth.isLoading 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Simpan Perubahan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: darkBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBlue, width: 2)
        )
      ),
      validator: (val) => val!.isEmpty ? "$label tidak boleh kosong" : null,
    );
  }
}

// ================= 2. HALAMAN RIWAYAT LAPORAN =================
class HistoryScreen extends StatelessWidget {
  final ApiService api = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        title: Text("Riwayat Laporan", style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
      ),
      body: FutureBuilder<List<Item>>(
        future: api.getMyItems(), // Mengambil item milik user sendiri
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[300]),
                  SizedBox(height: 10),
                  Text("Belum ada riwayat laporan.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(20),
            itemCount: snapshot.data!.length,
            separatorBuilder: (c, i) => SizedBox(height: 15),
            itemBuilder: (context, index) {
              Item item = snapshot.data![index];
              bool isLost = item.tipeLaporan == "hilang";
              return ListTile(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(item: item))),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isLost ? Colors.red[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Icon(
                    isLost ? Icons.search_off : Icons.check_circle_outline,
                    color: isLost ? Colors.red : Colors.green,
                  ),
                ),
                title: Text(item.namaBarang, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item.lokasi ?? "-"),
                trailing: Icon(Icons.chevron_right),
              );
            },
          );
        },
      ),
    );
  }
}

// ================= 3. HALAMAN NOTIFIKASI (UI SAJA) =================
class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Notifikasi", style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
      ),
      body: ListView(
        children: [
          _notifItem("Laporan Disetujui", "Laporan kehilangan 'Dompet' Anda telah disetujui admin.", "2 Jam yang lalu"),
          Divider(),
          _notifItem("Barang Ditemukan!", "Seseorang mengaku menemukan barang yang cocok dengan laporan Anda.", "1 Hari yang lalu", isUnread: true),
          Divider(),
          _notifItem("Info Sistem", "Jangan lupa update profil Anda untuk kemudahan komunikasi.", "3 Hari yang lalu"),
        ],
      ),
    );
  }

  Widget _notifItem(String title, String body, String time, {bool isUnread = false}) {
    return Container(
      color: isUnread ? Colors.blue[50] : Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notifications, color: darkBlue, size: 28),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text(body, style: TextStyle(color: Colors.grey[700])),
                SizedBox(height: 8),
                Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          if (isUnread) Icon(Icons.circle, size: 10, color: Colors.red)
        ],
      ),
    );
  }
}

// ================= 4. HALAMAN BANTUAN =================
class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Bantuan & Dukungan", style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("FAQ (Pertanyaan Umum)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            _faqTile("Bagaimana cara melapor barang hilang?", "Klik tombol '+' di halaman utama, pilih kategori 'Lost', dan isi formulir."),
            _faqTile("Bagaimana jika barang saya ditemukan?", "Anda akan mendapatkan notifikasi jika ada orang yang menemukan barang serupa."),
            _faqTile("Apakah data saya aman?", "Ya, kami menjaga privasi data mahasiswa UPN."),
            
            SizedBox(height: 30),
            Text("Hubungi Kami", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            ListTile(
              leading: Icon(Icons.email, color: darkBlue),
              title: Text("Email Support"),
              subtitle: Text("help@upn.ac.id"),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: darkBlue),
              title: Text("Call Center"),
              subtitle: Text("021-12345678"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: TextStyle(color: Colors.grey[700])),
        )
      ],
    );
  }
}