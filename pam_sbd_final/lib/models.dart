class User {
  final int id;
  final String namaLengkap;
  final String nim;
  final String email;
  final String? nomorTelepon;
  final String role; // 'mahasiswa' or 'admin'

  User({
    required this.id,
    required this.namaLengkap,
    required this.nim,
    required this.email,
    this.nomorTelepon,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      namaLengkap: json['nama_lengkap'] ?? '',
      nim: json['nim'] ?? '',
      email: json['email'] ?? '',
      nomorTelepon: json['nomor_telepon'],
      role: json['role'] ?? 'mahasiswa',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'nim': nim,
      'email': email,
      'nomor_telepon': nomorTelepon,
      'role': role,
    };
  }
}

class Kategori {
  final int id;
  final String namaKategori;
  final String? deskripsi;

  Kategori({
    required this.id,
    required this.namaKategori,
    this.deskripsi,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'],
      namaKategori: json['nama_kategori'] ?? '',
      deskripsi: json['deskripsi'],
    );
  }
}

class Lokasi {
  final int id;
  final String namaLokasi;
  final String? deskripsi;

  Lokasi({
    required this.id,
    required this.namaLokasi,
    this.deskripsi,
  });

  factory Lokasi.fromJson(Map<String, dynamic> json) {
    return Lokasi(
      id: json['id'],
      namaLokasi: json['nama_lokasi'] ?? '',
      deskripsi: json['deskripsi'],
    );
  }
}

class FotoBarang {
  final int id;
  final int idBarang;
  final String urlFoto;

  FotoBarang({
    required this.id,
    required this.idBarang,
    required this.urlFoto,
  });

  factory FotoBarang.fromJson(Map<String, dynamic> json) {
    return FotoBarang(
      id: json['id'],
      idBarang: json['id_barang'],
      urlFoto: json['url_foto'] ?? '',
    );
  }
}

class Barang {
  final int id;
  final String namaBarang;
  final String deskripsi;
  final String? gambarUrl;
  final String tipeLaporan; // 'hilang' | 'ditemukan'
  final String status; // 'open' | 'proses_klaim' | 'selesai'
  final String statusVerifikasi;
  final DateTime? tanggalKejadian;
  final DateTime createdAt;
  
  // Relations
  final User? pelapor;
  final Kategori? kategori;
  final Lokasi? lokasi;
  final List<FotoBarang> fotoLain;
  
  // ✅ TAMBAHAN: Untuk menampung data bukti penyelesaian
  final List<BuktiPengambilan> bukti; 

  Barang({
    required this.id,
    required this.namaBarang,
    required this.deskripsi,
    this.gambarUrl,
    required this.tipeLaporan,
    required this.status,
    required this.statusVerifikasi,
    this.tanggalKejadian,
    required this.createdAt,
    this.pelapor,
    this.kategori,
    this.lokasi,
    this.fotoLain = const [],
    this.bukti = const [], // ✅ Default kosong
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    // 1. Parsing Foto Lain
    var listFoto = json['foto'] as List? ?? [];
    List<FotoBarang> fotoList = listFoto.map((i) => FotoBarang.fromJson(i)).toList();

    // ✅ 2. Parsing Bukti Pengambilan (TAMBAHAN)
    // Pastikan backend mengirim key 'bukti' (via ->load('bukti'))
    var listBukti = json['bukti'] as List? ?? [];
    List<BuktiPengambilan> buktiList = listBukti.map((i) => BuktiPengambilan.fromJson(i)).toList();

    return Barang(
      id: json['id'],
      namaBarang: json['nama_barang'] ?? 'Tanpa Nama',
      deskripsi: json['deskripsi'] ?? '',
      gambarUrl: json['gambar_url'],
      tipeLaporan: json['tipe_laporan'] ?? 'hilang',
      status: json['status'] ?? 'open',
      statusVerifikasi: json['status_verifikasi'] ?? 'belum_diverifikasi',
      
      // Handle Tanggal (Cegah crash format)
      tanggalKejadian: json['tanggal_kejadian'] != null 
          ? DateTime.tryParse(json['tanggal_kejadian'].toString()) 
          : null,
      
      createdAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      
      // Handle Pelapor
      pelapor: json['pelapor'] is Map<String, dynamic> 
          ? User.fromJson(json['pelapor']) 
          : null,

      // Handle Kategori
      kategori: json['kategori'] is Map<String, dynamic>
          ? Kategori.fromJson(json['kategori'])
          : (json['kategori'] is String 
              ? Kategori(id: 0, namaKategori: json['kategori']) 
              : null),

      // Handle Lokasi
      lokasi: json['lokasi'] is Map<String, dynamic>
          ? Lokasi.fromJson(json['lokasi'])
          : (json['lokasi'] is String 
              ? Lokasi(id: 0, namaLokasi: json['lokasi']) 
              : null),

      fotoLain: fotoList,
      bukti: buktiList, // ✅ Masukkan ke object
    );
  }
}

class KlaimPenemuan {
  final int id;
  final int idBarang;
  final int idPenemu;
  final String lokasiDitemukan;
  final String? deskripsiPenemuan;
  final String? fotoPenemuan;
  final String statusKlaim; // 'menunggu_verifikasi_pemilik', 'diterima_pemilik', etc.
  final DateTime createdAt;

  // Relations
  final User? penemu;
  final Barang? barang;

  KlaimPenemuan({
    required this.id,
    required this.idBarang,
    required this.idPenemu,
    required this.lokasiDitemukan,
    this.deskripsiPenemuan,
    this.fotoPenemuan,
    required this.statusKlaim,
    required this.createdAt,
    this.penemu,
    this.barang,
  });

  factory KlaimPenemuan.fromJson(Map<String, dynamic> json) {
    return KlaimPenemuan(
      id: json['id'],
      idBarang: json['id_barang'],
      idPenemu: json['id_penemu'],
      lokasiDitemukan: json['lokasi_ditemukan'] ?? '',
      deskripsiPenemuan: json['deskripsi_penemuan'],
      fotoPenemuan: json['foto_penemuan'],
      statusKlaim: json['status_klaim'] ?? 'menunggu_verifikasi_pemilik',
      createdAt: DateTime.parse(json['created_at']),
      
      // Relasi opsional, tergantung apakah backend mengirimnya
      penemu: json['penemu'] != null ? User.fromJson(json['penemu']) : null,
      barang: json['barang'] != null ? Barang.fromJson(json['barang']) : null,
    );
  }
}

class BuktiPengambilan {
  final int id;
  final int idBarang;
  final String fotoBukti;
  final String? catatan;
  final DateTime tanggalPengambilan;

  BuktiPengambilan({
    required this.id,
    required this.idBarang,
    required this.fotoBukti,
    this.catatan,
    required this.tanggalPengambilan,
  });

  factory BuktiPengambilan.fromJson(Map<String, dynamic> json) {
    return BuktiPengambilan(
      id: json['id'],
      idBarang: json['id_barang'],
      fotoBukti: json['foto_bukti'] ?? '',
      catatan: json['catatan'],
      tanggalPengambilan: DateTime.parse(json['tanggal_pengambilan']),
    );
  }
}

class Notifikasi {
  final int id;
  final String judul;
  final String pesan;
  final bool sudahDibaca;
  final DateTime createdAt;

  Notifikasi({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.sudahDibaca,
    required this.createdAt,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> json) {
    return Notifikasi(
      id: json['id'],
      judul: json['judul'] ?? '',
      pesan: json['pesan'] ?? '',
      // Konversi integer 0/1 atau boolean dari JSON
      sudahDibaca: json['sudah_dibaca'] == true || json['sudah_dibaca'] == 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}