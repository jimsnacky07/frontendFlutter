# Setup Backend Laravel untuk Upload Foto

## 1. Update Model Keuangan

```php
<?php
// app/Models/Keuangan.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Keuangan extends Model
{
    use HasFactory;

    protected $table = 'keuangan';
    
    protected $fillable = [
        'id_penghuni', // Sesuaikan dengan nama field di database
        'tagihan_id', 
        'bayar', // Sesuaikan dengan nama field di database
        'tgl_bayar', // Sesuaikan dengan nama field di database
        'keterangan',
        'foto',
    ];

    protected $casts = [
        'tgl_bayar' => 'date',
    ];

    public function penghuni()
    {
        return $this->belongsTo(Penghuni::class, 'id_penghuni');
    }

    public function tagihan()
    {
        return $this->belongsTo(Tagihan::class);
    }
}
```

## 2. Update Migration (jika belum ada field foto)

```php
<?php
// database/migrations/xxxx_xx_xx_add_foto_to_keuangan_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('keuangan', function (Blueprint $table) {
            $table->string('foto')->nullable()->after('keterangan');
        });
    }

    public function down()
    {
        Schema::table('keuangan', function (Blueprint $table) {
            $table->dropColumn('foto');
        });
    }
};
```

## 3. PERBAIKAN Controller Keuangan - Sesuai Database

```php
<?php
// app/Http/Controllers/Api/KeuanganController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Keuangan;
use App\Models\Tagihan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class KeuanganController extends Controller
{
    // Ambil semua data keuangan
    public function index()
    {
        try {
            $data = Keuangan::with(['penghuni', 'tagihan'])->get()->map(function($keuangan){
                // Jika ada foto, tambahkan full URL
                if ($keuangan->foto) {
                    $keuangan->foto = asset('storage/' . $keuangan->foto);
                }
                return $keuangan;
            });
            
            return response()->json([
                'success' => true,
                'data' => $data
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data: ' . $e->getMessage()
            ], 500);
        }
    }

    // Tampilkan data keuangan berdasarkan ID
    public function show($id)
    {
        try {
            $keuangan = Keuangan::with(['penghuni', 'tagihan'])->find($id);
            if (!$keuangan) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data tidak ditemukan'
                ], 404);
            }
            
            // Jika ada foto, tambahkan full URL
            if ($keuangan->foto) {
                $keuangan->foto = asset('storage/' . $keuangan->foto);
            }
            
            return response()->json([
                'success' => true,
                'data' => $keuangan
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data: ' . $e->getMessage()
            ], 500);
        }
    }

    // Simpan data keuangan dan ubah status tagihan menjadi "Lunas"
    public function store(Request $request)
    {
        try {
            $data = $request->validate([
                'id_penghuni' => 'required|string', // Sesuaikan dengan tipe data di database
                'tagihan_id' => 'nullable|integer|exists:tagihan,id',
                'bayar' => 'required|numeric', // Sesuaikan dengan nama field di database
                'tgl_bayar' => 'required|date', // Sesuaikan dengan nama field di database
                'keterangan' => 'nullable|string',
                'foto' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            ]);

            // Siapkan data untuk disimpan
            $keuanganData = [
                'id_penghuni' => $data['id_penghuni'],
                'tagihan_id' => $data['tagihan_id'] ?? null,
                'bayar' => $data['bayar'],
                'tgl_bayar' => $data['tgl_bayar'],
                'keterangan' => $data['keterangan'] ?? null,
            ];

            // Handle upload foto jika ada
            if ($request->hasFile('foto')) {
                $file = $request->file('foto');
                $filename = 'keuangan_' . time() . '_' . $file->getClientOriginalName();
                
                // Simpan file ke storage/app/public/foto_keuangan
                $path = $file->storeAs('foto_keuangan', $filename, 'public');
                
                // Simpan path ke database
                $keuanganData['foto'] = $path;
            }

            // Simpan ke tabel keuangan
            $keuangan = Keuangan::create($keuanganData);

            // Update status tagihan menjadi Lunas jika ada tagihan_id
            $tagihan = null;
            if ($data['tagihan_id']) {
                $tagihan = Tagihan::find($data['tagihan_id']);
                if ($tagihan) {
                    $tagihan->status = 'Lunas';
                    $tagihan->save();
                }
            }

            // Jika ada foto, tambahkan full URL ke response
            if ($keuangan->foto) {
                $keuangan->foto = asset('storage/' . $keuangan->foto);
            }

            return response()->json([
                'success' => true,
                'message' => 'Pembayaran berhasil',
                'data' => $keuangan
            ], 201);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan data: ' . $e->getMessage()
            ], 500);
        }
    }

    // Update data keuangan
    public function update(Request $request, $id)
    {
        try {
            $keuangan = Keuangan::find($id);
            if (!$keuangan) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data tidak ditemukan'
                ], 404);
            }

            $data = $request->all();
            $keuangan->update($data);

            return response()->json([
                'success' => true,
                'message' => 'Data berhasil diupdate',
                'data' => $keuangan
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal update data: ' . $e->getMessage()
            ], 500);
        }
    }

    // Hapus data keuangan
    public function destroy($id)
    {
        try {
            $keuangan = Keuangan::find($id);
            if (!$keuangan) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data tidak ditemukan'
                ], 404);
            }

            // Hapus file foto jika ada
            if ($keuangan->foto) {
                Storage::disk('public')->delete($keuangan->foto);
            }

            $keuangan->delete();

            return response()->json([
                'success' => true,
                'message' => 'Data berhasil dihapus'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal hapus data: ' . $e->getMessage()
            ], 500);
        }
    }
}
```

## 4. Update Routes

```php
<?php
// routes/api.php

use App\Http\Controllers\Api\KeuanganController;

// Pastikan route sudah ada
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/keuangan', [KeuanganController::class, 'store']);
    Route::get('/keuangan', [KeuanganController::class, 'index']);
    Route::get('/keuangan/{id}', [KeuanganController::class, 'show']);
    Route::put('/keuangan/{id}', [KeuanganController::class, 'update']);
    Route::delete('/keuangan/{id}', [KeuanganController::class, 'destroy']);
});
```

## 5. Setup Storage Link

Jalankan command ini di terminal Laravel:

```bash
php artisan storage:link
```

## 6. Pastikan Folder Storage Writable

```bash
chmod -R 775 storage/
chmod -R 775 bootstrap/cache/
```

## 7. Update .env untuk File Upload

```env
FILESYSTEM_DISK=public
```

## 8. Test API

Setelah setup, test dengan Postman atau curl:

```bash
curl -X POST http://your-domain/api/keuangan \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json" \
  -F "id_penghuni=PH001" \
  -F "tagihan_id=1" \
  -F "bayar=100000" \
  -F "tgl_bayar=2024-01-15" \
  -F "keterangan=Pembayaran via aplikasi" \
  -F "foto=@/path/to/image.jpg"
```

## Troubleshooting

### Jika masih error 500:

1. **Cek Laravel logs:**
```bash
tail -f storage/logs/laravel.log
```

2. **Cek permission folder:**
```bash
ls -la storage/
ls -la bootstrap/cache/
```

3. **Clear cache:**
```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
```

4. **Restart server:**
```bash
php artisan serve
```

## PERUBAHAN PENTING:

1. **Field mapping diperbaiki sesuai database:**
   - `penghuni_id` → `id_penghuni`
   - `jumlah` → `bayar`
   - `tanggal` → `tgl_bayar`

2. **Tipe data `id_penghuni`** diubah menjadi string (sesuai dengan PH001, PH002)

3. **Upload foto diintegrasikan** dalam satu proses

4. **Response format konsisten** dengan yang diharapkan Flutter

5. **Error handling yang lebih baik** 