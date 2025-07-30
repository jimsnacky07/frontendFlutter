# Kos Management App

Aplikasi Flutter untuk manajemen kos dengan fitur login, registrasi, dan dashboard.

## Fitur

- **Login & Registrasi**: Sistem autentikasi dengan validasi email dan password
- **Dashboard**: Tampilan utama dengan saldo, akses cepat, dan gambar kamar
- **Keuangan**: Manajemen keuangan kos
- **Tagihan**: Sistem tagihan penghuni
- **Penghuni**: Data penghuni kos
- **Laporan**: Laporan keuangan dan penghuni
- **Session Management**: Penyimpanan token dan data user

## Struktur Database

### Tabel Users
```sql
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
);
```

## Setup Laravel Backend

1. **Install Laravel Sanctum**:
```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

2. **Buat migration untuk kolom phone**:
```bash
php artisan make:migration add_phone_to_users_table
```

3. **Edit migration file**:
```php
public function up()
{
    Schema::table('users', function (Blueprint $table) {
        $table->string('phone')->nullable()->after('email');
    });
}
```

4. **Jalankan migration**:
```bash
php artisan migrate
```

5. **Buat AuthController**:
```bash
php artisan make:controller AuthController
```

6. **Buat DashboardController**:
```bash
php artisan make:controller DashboardController
```

7. **Update routes/api.php** dengan endpoint yang diperlukan

8. **Konfigurasi CORS** untuk mengizinkan request dari Flutter

## Setup Flutter App

1. **Install dependencies**:
```bash
flutter pub get
```

2. **Update API URL** di `lib/api_service.dart`:
```dart
static const String baseUrl = 'http://your-laravel-url.com/api';
```

3. **Jalankan aplikasi**:
```bash
flutter run
```

## API Endpoints

### Authentication
- `POST /api/login` - Login user
- `POST /api/register` - Registrasi user baru
- `POST /api/logout` - Logout user (memerlukan token)

### Protected Routes
- `GET /api/user` - Data user yang sedang login
- `GET /api/dashboard` - Data dashboard

## Struktur File

```
lib/
├── main.dart              # Entry point aplikasi
├── login.dart             # Halaman login & registrasi
├── dashboard.dart         # Halaman dashboard
├── api_service.dart       # Service untuk API calls
├── auth_service.dart      # Service untuk session management
├── keuangan.dart          # Halaman keuangan
├── tagihan.dart           # Halaman tagihan
├── penghuni.dart          # Halaman penghuni
├── laporan.dart           # Halaman laporan
└── welcome.dart           # Halaman syarat & ketentuan
```

## Dependencies

- `flutter_spinkit`: Untuk loading animation
- `http`: Untuk HTTP requests
- `shared_preferences`: Untuk penyimpanan local data

## Cara Penggunaan

1. **Login**: Masukkan email dan password yang sudah terdaftar
2. **Registrasi**: Isi form registrasi dengan data lengkap
3. **Dashboard**: Setelah login, user akan diarahkan ke dashboard
4. **Logout**: Klik tombol "Log Out" di header untuk keluar

## Validasi

### Login
- Email harus valid
- Password tidak boleh kosong
- Email dan password harus sesuai dengan data di database

### Registrasi
- Nama tidak boleh kosong
- Email harus valid dan unik
- Nomor telepon tidak boleh kosong
- Password minimal 6 karakter
- Konfirmasi password harus sama

## Keamanan

- Password di-hash menggunakan bcrypt
- Token authentication menggunakan Laravel Sanctum
- Session management menggunakan SharedPreferences
- Validasi input di client dan server side

## Troubleshooting

1. **API tidak terhubung**: Pastikan URL API sudah benar dan server Laravel berjalan
2. **CORS error**: Pastikan CORS sudah dikonfigurasi di Laravel
3. **Token expired**: User akan diarahkan ke halaman login
4. **Validasi gagal**: Periksa format input sesuai dengan validasi yang ditentukan

## Testing

### Test API dengan curl:
```bash
# Register
curl -X POST http://localhost:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","phone":"08123456789","password":"password","password_confirmation":"password"}'

# Login
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

### Test Flutter App:
1. Jalankan aplikasi dengan `flutter run`
2. Test fitur login dengan user yang sudah ada
3. Test fitur registrasi dengan data baru
4. Test logout dan session management
