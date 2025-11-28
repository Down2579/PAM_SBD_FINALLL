<?php
namespace App\Policies;
use App\Models\User;
use App\Models\Barang;

class BarangPolicy
{
    public function update(User $user, Barang $barang)
    {
        return $user->role === 'admin' || $user->id === $barang->id_pelapor;
    }

    public function delete(User $user, Barang $barang)
    {
        return $user->role === 'admin' || $user->id === $barang->id_pelapor;
    }
}
