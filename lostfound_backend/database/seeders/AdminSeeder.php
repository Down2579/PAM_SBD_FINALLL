<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AdminSeeder extends Seeder
{
    public function run()
    {
        User::create([
            'nama_lengkap'  => 'Admin',
            'nim'           => '000001',
            'email'         => 'admin@gmail.com',
            'password'      => Hash::make('admin123'),
            'nomor_telepon' => '081234567890',
            'role'          => 'admin'
        ]);
    }
}
