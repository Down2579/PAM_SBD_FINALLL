class User {
  final int id;
  final String namaLengkap;
  final String nim;
  final String email;
  final String role;
  final String? token; // Token bisa null di awal
  final String? nomorTelepon;

  User({
    required this.id,
    required this.namaLengkap,
    required this.nim,
    required this.email,
    required this.role,
    this.token,
    this.nomorTelepon,
  });

  factory User.fromJson(Map<String, dynamic> json, String? token) {
    return User(
      id: json['id'],
      namaLengkap: json['nama_lengkap'],
      nim: json['nim'] ?? '-',
      email: json['email'],
      role: json['role'] ?? 'mahasiswa',
      nomorTelepon: json['nomor_telepon'],
      token: token,
    );
  }
}

class Item {
  final int id;
  final String namaBarang;
  final String deskripsi;
  final String tipeLaporan; // 'hilang' atau 'ditemukan'
  final String status;
  final DateTime tanggalKejadian; // Data asli berupa DateTime

  final String? lokasi;
  final String? kategori;

  final int idPelapor;
  final String? pelaporNama;

  final String? gambarUrl;

  Item({
    required this.id,
    required this.namaBarang,
    required this.deskripsi,
    required this.tipeLaporan,
    required this.status,
    required this.tanggalKejadian,
    this.lokasi,
    this.kategori,
    required this.idPelapor,
    this.pelaporNama,
    this.gambarUrl,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      namaBarang: json['nama_barang'],
      deskripsi: json['deskripsi'],
      // Pastikan backend mengirim 'tipe_laporan' (snake_case)
      tipeLaporan: json['tipe_laporan'] ?? 'hilang', 
      status: json['status'] ?? 'open',
      // Parsing string tanggal dari API ke DateTime Dart
      tanggalKejadian: DateTime.parse(json['tanggal_kejadian'] ?? DateTime.now().toString()),
      lokasi: json['lokasi_nama'] ?? json['lokasi'] ?? '-',
      kategori: json['kategori_nama'] ?? 'Lainnya',
      // Pastikan konversi ke int aman
      idPelapor: int.tryParse(json['id_pelapor'].toString()) ?? 0,
      pelaporNama: json['pelapor_nama'] ?? 'Anonim',
      gambarUrl: json['gambar_url'] ?? json['gambar'],
    );
  }

  // ==============================================================
  // GETTER TAMBAHAN (PENTING AGAR UI TIDAK ERROR)
  // ==============================================================

  // 1. Getter 'waktu': Mengubah DateTime ke String format "MM/dd/yyyy"
  // Ini yang dicari oleh error "getter waktu isn't defined"
  String get waktu {
    return "${tanggalKejadian.month}/${tanggalKejadian.day}/${tanggalKejadian.year}";
  }

  // 2. Getter 'userId': Alias untuk idPelapor (jika UI pake item.userId)
  int get userId => idPelapor;

  // 3. Getter 'gambar': Alias untuk gambarUrl (jika UI pake item.gambar)
  String? get gambar => gambarUrl;
}