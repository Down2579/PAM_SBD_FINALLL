CREATE DATABASE lostfoundd;

-- =====================================================
-- 1. ENUM TYPES
-- =====================================================

CREATE TYPE user_role AS ENUM ('mahasiswa', 'admin');
CREATE TYPE report_type AS ENUM ('hilang', 'ditemukan');
CREATE TYPE item_status AS ENUM ('open', 'proses_klaim', 'selesai');
CREATE TYPE claim_status AS ENUM ('pending', 'disetujui', 'ditolak');

-- =====================================================
-- 2. TABEL UTAMA
-- =====================================================

-- 2.1. Tabel Pengguna
CREATE TABLE Users (
    id SERIAL PRIMARY KEY,
    nama_lengkap VARCHAR(100) NOT NULL,
    nim VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nomor_telepon VARCHAR(15),
    role user_role DEFAULT 'mahasiswa',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2.2. Kategori
CREATE TABLE Kategori (
    id SERIAL PRIMARY KEY,
    nama_kategori VARCHAR(50) UNIQUE NOT NULL,
    deskripsi TEXT
);

-- 2.3. Lokasi
CREATE TABLE Lokasi (
    id SERIAL PRIMARY KEY,
    nama_lokasi VARCHAR(100) UNIQUE NOT NULL,
    deskripsi TEXT
);

-- 2.4. Barang
CREATE TABLE Barang (
    id SERIAL PRIMARY KEY,
    nama_barang VARCHAR(100) NOT NULL,
    deskripsi TEXT NOT NULL,
    gambar_url VARCHAR(255),
    tipe_laporan report_type NOT NULL,
    status item_status DEFAULT 'open',
    tanggal_kejadian DATE,

    id_pelapor INTEGER NOT NULL REFERENCES Users(id),
    id_kategori INTEGER NOT NULL REFERENCES Kategori(id),
    id_lokasi INTEGER REFERENCES Lokasi(id),

    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2.5. Klaim
CREATE TABLE Klaim (
    id SERIAL PRIMARY KEY,
    id_barang INTEGER NOT NULL REFERENCES Barang(id) ON DELETE CASCADE,
    id_pengklaim INTEGER NOT NULL REFERENCES Users(id),

    pesan_klaim TEXT NOT NULL,
    status_klaim claim_status DEFAULT 'pending',
    tanggal_klaim TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 3. TABEL TAMBAHAN (DIREKOMENDASI)
-- =====================================================

-- 3.1. Foto Barang (Multi-Foto)
CREATE TABLE Foto_Barang (
    id SERIAL PRIMARY KEY,
    id_barang INTEGER NOT NULL REFERENCES Barang(id) ON DELETE CASCADE,
    url_foto VARCHAR(255) NOT NULL,

    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3.2. Bukti Pengambilan Barang
CREATE TABLE Bukti_Pengambilan (
    id SERIAL PRIMARY KEY,
    id_barang INTEGER NOT NULL REFERENCES Barang(id) ON DELETE CASCADE,
    id_admin INTEGER NOT NULL REFERENCES Users(id),

    foto_bukti VARCHAR(255) NOT NULL,
    catatan TEXT,
    tanggal_pengambilan TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3.3. Notifikasi Pengguna
CREATE TABLE Notifikasi (
    id SERIAL PRIMARY KEY,
    id_pengguna INTEGER NOT NULL REFERENCES Users(id),
    judul VARCHAR(150) NOT NULL,
    pesan TEXT NOT NULL,
    sudah_dibaca BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3.4. Activity Logs (Audit Trail)
CREATE TABLE Activity_Logs (
    id SERIAL PRIMARY KEY,
    id_pengguna INTEGER REFERENCES Users(id),
    aktivitas TEXT NOT NULL,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 4. FUNGSI GLOBAL
-- =====================================================

-- 4.1. Update timestamp otomatis
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. TRIGGER TIMESTAMP
-- =====================================================

CREATE TRIGGER set_timestamp_barang
BEFORE UPDATE ON Barang
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_timestamp_foto_barang
BEFORE UPDATE ON Foto_Barang
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_timestamp_bukti_pengambilan
BEFORE UPDATE ON Bukti_Pengambilan
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- =====================================================
-- 6. FUNGSI LOGIC APLIKASI
-- =====================================================

-- 6.1. Cegah pelapor mengklaim barangnya sendiri
CREATE OR REPLACE FUNCTION prevent_self_claim_on_lost_item()
RETURNS TRIGGER AS $$
DECLARE
    item_pelapor INTEGER;
    tipe report_type;
BEGIN
    SELECT id_pelapor, tipe_laporan INTO item_pelapor, tipe
    FROM Barang WHERE id = NEW.id_barang;

    IF tipe = 'hilang' AND NEW.id_pengklaim = item_pelapor THEN
        RAISE EXCEPTION 'Tidak dapat mengklaim barang yang Anda laporkan sendiri.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_self_claim
BEFORE INSERT ON Klaim
FOR EACH ROW EXECUTE FUNCTION prevent_self_claim_on_lost_item();

-- 6.2. Update status item berdasarkan status klaim
CREATE OR REPLACE FUNCTION update_item_status_on_claim_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status_klaim = 'disetujui' THEN
        UPDATE Barang SET status = 'selesai', updated_at = NOW()
        WHERE id = NEW.id_barang;

    ELSIF NEW.status_klaim = 'ditolak' THEN
        UPDATE Barang SET status = 'open', updated_at = NOW()
        WHERE id = NEW.id_barang;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_claim_status
AFTER UPDATE ON Klaim
FOR EACH ROW
WHEN (OLD.status_klaim IS DISTINCT FROM NEW.status_klaim)
EXECUTE FUNCTION update_item_status_on_claim_change();

-- 6.3. Otomatis membuat notifikasi saat klaim berubah
CREATE OR REPLACE FUNCTION send_notification_on_claim_status_change()
RETURNS TRIGGER AS $$
DECLARE
    idPelapor INTEGER;
BEGIN
    SELECT id_pelapor INTO idPelapor FROM Barang WHERE id = NEW.id_barang;

    INSERT INTO Notifikasi (id_pengguna, judul, pesan)
    VALUES (
        idPelapor,
        'Status Klaim Berubah',
        'Status klaim barang Anda berubah menjadi: ' || NEW.status_klaim
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_claim_status_change
AFTER UPDATE ON Klaim
FOR EACH ROW
WHEN (OLD.status_klaim IS DISTINCT FROM NEW.status_klaim)
EXECUTE FUNCTION send_notification_on_claim_status_change();

-- 6.4. Saat bukti pengambilan dibuat → Barang otomatis selesai
CREATE OR REPLACE FUNCTION mark_item_completed_on_pickup()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Barang SET status = 'selesai', updated_at = NOW()
    WHERE id = NEW.id_barang;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_item_complete_on_pickup
AFTER INSERT ON Bukti_Pengambilan
FOR EACH ROW EXECUTE FUNCTION mark_item_completed_on_pickup();

-- 6.5. Kirim notifikasi bahwa barang telah diambil
CREATE OR REPLACE FUNCTION notify_pickup_completed()
RETURNS TRIGGER AS $$
DECLARE
    pelapor INTEGER;
BEGIN
    SELECT id_pelapor INTO pelapor FROM Barang WHERE id = NEW.id_barang;

    INSERT INTO Notifikasi (id_pengguna, judul, pesan)
    VALUES (
        pelapor,
        'Barang Telah Diambil',
        'Barang Anda telah diambil dan proses selesai.'
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER send_notification_pickup
AFTER INSERT ON Bukti_Pengambilan
FOR EACH ROW EXECUTE FUNCTION notify_pickup_completed();
