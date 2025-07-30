<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Tagihan extends Model
{
    protected $table = 'tagihan';
    protected $primaryKey = 'id';
    public $incrementing = true;
    public $timestamps = false;
    
    protected $fillable = [
        'id_penghuni',
        'bulan',
        'tahun', 
        'tagihan',
        'status'
    ];

    // Relationships
    public function penghuni()
    {
        return $this->belongsTo(Penghuni::class, 'id_penghuni', 'id');
    }

    public function keuangan()
    {
        return $this->hasMany(Keuangan::class, 'tagihan_id', 'id');
    }

    // Helper methods
    public function getFormattedAmount()
    {
        return 'Rp ' . number_format($this->tagihan, 0, ',', '.');
    }

    public function getFormattedPeriod()
    {
        return $this->bulan . ' ' . $this->tahun;
    }

    public function isLunas()
    {
        return $this->status === 'Lunas';
    }

    public function isBelumLunas()
    {
        return $this->status === 'Belum Lunas';
    }
} 