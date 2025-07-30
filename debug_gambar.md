# Debug Masalah Gambar Tidak Muncul

## Langkah Debug:

### 1. Cek Response API
Buka Flutter app dan lihat console log untuk melihat:
- Response dari `getKeuanganWithFoto`
- Data transaksi yang diterima
- URL gambar yang dikirim

### 2. Cek Backend Laravel
Pastikan controller sudah mengirim URL lengkap:
```php
// Di KeuanganController index()
if ($keuangan->foto) {
    $keuangan->foto = asset('storage/' . $keuangan->foto);
}
```

### 3. Cek Storage Link
Pastikan storage link sudah dibuat:
```bash
php artisan storage:link
```

### 4. Cek File Fisik
Pastikan file gambar ada di folder:
```
public/storage/keuangan/[nama_file]
```

### 5. Test URL Gambar
Buka browser dan coba akses URL gambar langsung:
```
http://10.238.115.156:8000/storage/keuangan/[nama_file]
```

### 6. Cek Permission
Pastikan folder storage bisa diakses:
```bash
chmod -R 775 storage
chmod -R 775 public/storage
```

## Kemungkinan Masalah:

1. **URL gambar tidak lengkap** - Backend tidak mengirim URL lengkap
2. **File tidak tersimpan** - Upload gagal atau file tidak ada
3. **Permission folder** - Folder storage tidak bisa diakses
4. **Storage link belum dibuat** - Link symbolic belum dibuat
5. **CORS issue** - Browser memblokir request gambar

## Solusi:

1. **Update controller** dengan kode yang sudah diberikan
2. **Buat storage link**: `php artisan storage:link`
3. **Restart server**: `php artisan serve`
4. **Test upload** gambar baru
5. **Cek console log** Flutter untuk debug info 