# Setup Laravel Storage untuk Upload File

## 1. Buat Storage Link
Jalankan command berikut di terminal Laravel Anda:

```bash
php artisan storage:link
```

## 2. Buat Folder untuk Keuangan
Buat folder `keuangan` di dalam `storage/app/public/`:

```bash
mkdir storage/app/public/keuangan
```

## 3. Set Permission (untuk Linux/Mac)
```bash
chmod -R 775 storage
chmod -R 775 bootstrap/cache
```

## 4. Pastikan .env sudah benar
```env
FILESYSTEM_DISK=public
```

## 5. Test Upload
Setelah setup selesai, coba upload gambar dari Flutter app.

## Troubleshooting

### Jika masih error "The foto field must be a string":
1. Pastikan controller sudah diupdate dengan kode yang baru
2. Pastikan validation rule sudah berubah dari `'foto' => 'nullable|string'` menjadi `'foto' => 'nullable|file|image|mimes:jpeg,png,jpg,gif|max:2048'`
3. Restart server Laravel: `php artisan serve`

### Jika gambar tidak muncul:
1. Pastikan storage link sudah dibuat
2. Cek folder `public/storage/keuangan/` sudah ada
3. Pastikan permission folder sudah benar 