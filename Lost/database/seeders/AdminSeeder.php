<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'nama_lengkap' => 'Admin123',
            'nim' => '12345678',
            'email' => 'admin@lostfound.com',
            'password' => bcrypt('admin123'),
            'nomor_telepon' => '081234567890',
            'role' => 'admin',
        ]);
    }
}
