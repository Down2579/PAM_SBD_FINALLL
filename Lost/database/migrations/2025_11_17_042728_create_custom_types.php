<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Drop TYPE jika sudah ada
        DB::statement("DO $$ BEGIN
            IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
                DROP TYPE user_role;
            END IF;
        END $$;");

        DB::statement("DO $$ BEGIN
            IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'report_type') THEN
                DROP TYPE report_type;
            END IF;
        END $$;");

        DB::statement("DO $$ BEGIN
            IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'item_status') THEN
                DROP TYPE item_status;
            END IF;
        END $$;");

        DB::statement("DO $$ BEGIN
            IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'claim_status') THEN
                DROP TYPE claim_status;
            END IF;
        END $$;");

        // Buat TYPE baru
        DB::statement("CREATE TYPE user_role AS ENUM ('mahasiswa', 'admin');");
        DB::statement("CREATE TYPE report_type AS ENUM ('hilang', 'ditemukan');");
        DB::statement("CREATE TYPE item_status AS ENUM ('open', 'proses_klaim', 'selesai');");
        DB::statement("CREATE TYPE claim_status AS ENUM ('pending', 'disetujui', 'ditolak');");
    }

    public function down(): void
    {
        DB::statement("DROP TYPE IF EXISTS claim_status;");
        DB::statement("DROP TYPE IF EXISTS item_status;");
        DB::statement("DROP TYPE IF EXISTS report_type;");
        DB::statement("DROP TYPE IF EXISTS user_role;");
    }
};
