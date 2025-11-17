<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    /**
     * Register User
     */
    public function register(Request $req)
    {
        // Validasi request
        $req->validate([
            'nama_lengkap' => 'required',
            'nim' => 'required|unique:users',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:6|confirmed',
            'nomor_telepon' => 'nullable'
        ]);

        // Membuat user baru
        $user = User::create([
            'nama_lengkap' => $req->nama_lengkap,
            'nim' => $req->nim,
            'email' => $req->email,
            'password_hash' => bcrypt($req->password),
            'nomor_telepon' => $req->nomor_telepon,
            'role' => 'mahasiswa'
        ]);

        return response()->json([
            'message' => 'Register success',
            'user' => $user
        ], 201);
    }

    /**
     * Login User
     */
    public function login(Request $req)
    {
        // Validasi input
        $req->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        // Cari user berdasarkan email
        $user = User::where('email', $req->email)->first();

        // Cek apakah user tidak ditemukan atau password salah
        if (!$user || !password_verify($req->password, $user->password_hash)) {
            return response()->json(['error' => 'Invalid credentials'], 401);
        }

        // Generate Sanctum token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login success',
            'token' => $token,
            'user' => $user
        ]);
    }
}
