<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    protected $policies = [
        \App\Models\Barang::class => \App\Policies\BarangPolicy::class,
    ];

    public function boot()
    {
        $this->registerPolicies();
    }
}
