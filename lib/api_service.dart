import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti dengan URL API Laravel Anda
  static const String baseUrl = 'http://10.238.115.156:8000/api';
  
  // Mode simulasi untuk testing tanpa backend
  static const bool _simulationMode = false;
  
  // Data simulasi untuk testing
  static final Map<String, dynamic> _simulatedUsers = {
    'anton@gmail.com': {
      'id': 1,
      'name': 'Anton',
      'email': 'anton@gmail.com',
      'phone': '08123456789',
      'password': 'password123'
    },
    'test@example.com': {
      'id': 2,
      'name': 'Test User',
      'email': 'test@example.com',
      'phone': '08987654321',
      'password': 'password123'
    }
  };

  // Login user
  static Future<Map<String, dynamic>> login(String email, String password) async {
    if (_simulationMode) {
      // Simulasi login
      await Future.delayed(Duration(seconds: 1));
      
      final user = _simulatedUsers[email];
      if (user != null && user['password'] == password) {
        return {
          'success': true,
          'user': {
            'id': user['id'],
            'name': user['name'],
            'email': user['email'],
            'phone': user['phone'],
          },
          'token': 'simulated_token_for_api_access',
          'message': 'Login berhasil (Simulasi)'
        };
      } else {
        return {
          'success': false,
          'message': 'Email atau password salah (Simulasi)',
        };
      }
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi error: $e',
      };
    }
  }

  // Register user
  static Future<Map<String, dynamic>> register(String name, String email, String phone, String password) async {
    if (_simulationMode) {
      // Simulasi registrasi
      await Future.delayed(Duration(seconds: 1));
      
      if (_simulatedUsers.containsKey(email)) {
        return {
          'success': false,
          'message': 'Email sudah terdaftar (Simulasi)',
        };
      }
      
      final newId = _simulatedUsers.length + 1;
      _simulatedUsers[email] = {
        'id': newId,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password
      };
      
      return {
        'success': true,
        'user': {
          'id': newId,
          'name': name,
          'email': email,
          'phone': phone,
        },
        'message': 'Registrasi berhasil (Simulasi)'
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'user': data['user'],
          'message': 'Registrasi berhasil',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Registrasi gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi error: $e',
      };
    }
  }

  // Logout user
  static Future<Map<String, dynamic>> logout(String token) async {
    if (_simulationMode) {
      await Future.delayed(Duration(seconds: 1));
      return {
        'success': true,
        'message': 'Logout berhasil (Simulasi)',
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Logout berhasil',
        };
      } else {
        return {
          'success': false,
          'message': 'Logout gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi error: $e',
      };
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    if (_simulationMode) {
      await Future.delayed(Duration(seconds: 1));
      return {
        'success': true,
        'user': {
          'id': 1,
          'name': 'Anton',
          'email': 'anton@gmail.com',
          'phone': '08123456789',
        },
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengambil data user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi error: $e',
      };
    }
  }

  // Dashboard data
  static Future<Map<String, dynamic>> getDashboardData(String token) async {
    if (_simulationMode) {
      await Future.delayed(Duration(seconds: 1));
      return {
        'success': true,
        'data': {
          'saldo': 2500000,
          'kamar_images': [
            'asset/kamar01.jpg',
            'asset/kamar02.jpg',
            'asset/kamar03.jpg',
            'asset/kamar04.jpg',
            'asset/kamar05.jpg',
          ],
          'stats': {
            'sudah_bayar': 20,
            'total_kamar': 25,
            'belum_bayar': 5,
          }
        }
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengambil data dashboard',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi error: $e',
      };
    }
  }

  // Get Kamar data - TIDAK ADA MODE SIMULASI, LANGSUNG KE API
  static Future<Map<String, dynamic>> getKamar(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kamar'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': 'Gagal mengambil data kamar'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  // Get Penghuni data - Menggunakan ID spesifik untuk testing
  static Future<Map<String, dynamic>> getPenghuni(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/penghuni/user/user_id'), // Hardcode ID untuk tes
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // DEBUG: Cetak respons mentah dari API
      print('--- API Response: /penghuni/user/user_id--');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('-----------------------------');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Bungkus hasil dalam array karena halaman penghuni mengharapkan List
        return {'success': true, 'data': [data['data']]};
      } else {
        return {'success': false, 'message': 'Gagal mengambil data penghuni (Status: ${response.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  // Method khusus untuk mengambil data keuangan dengan foto
  static Future<Map<String, dynamic>> getKeuanganWithFoto(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/keuangan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('=== DEBUG: getKeuanganWithFoto Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==========================================');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Gagal mengambil data keuangan'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getPenghuniByUserId(String token, String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/penghuni/user/$userId'), // Pastikan endpoint sesuai API Anda
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    // Debug: Print response untuk melihat data foto
    print('=== DEBUG: getPenghuniByUserId Response ===');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('==========================================');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Debug: Print data keuangan untuk melihat field foto
      if (data['data'] != null && data['data']['keuangan'] != null) {
        print('=== DEBUG: Data Keuangan ===');
        for (int i = 0; i < data['data']['keuangan'].length; i++) {
          final keuangan = data['data']['keuangan'][i];
          print('Keuangan $i:');
          print('  - ID: ${keuangan['id']}');
          print('  - Foto: ${keuangan['foto']}');
          print('  - Keterangan: ${keuangan['keterangan']}');
        }
        print('===========================');
      }
      
      return {'success': true, 'data': data['data']};
    } else {
      return {'success': false, 'message': 'Gagal mengambil data penghuni'};
    }
  }

  static Future<Map<String, dynamic>> bayarTagihan(
    String token,
    int tagihanId,
    int userId,
    int jumlahBayar,
    String tanggalBayar,
    {String metode = 'Transfer', String keterangan = 'Pembayaran via aplikasi'}
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tagihan/$userId/edit'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tagihan_id': tagihanId,
        'status': 'Lunas',
        'jumlah_bayar': jumlahBayar,
        'tanggal_bayar': tanggalBayar,
        'metode_pembayaran': metode,
        'keterangan': keterangan,
      }),
    );
    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Pembayaran berhasil'};
    } else {
      print('Pembayaran gagal! Status: ${response.statusCode}');
      print('Response body: ${response.body}');
      String errorMsg = 'Pembayaran gagal';
      try {
        final error = json.decode(response.body);
        if (error is Map && error['message'] != null) {
          errorMsg = error['message'];
        } else if (error is String) {
          errorMsg = error;
        }
      } catch (e) {
        errorMsg = response.body;
      }
      return {'success': false, 'message': errorMsg};
    }
  }

  static Future<Map<String, dynamic>> ubahPassword(String token, String oldPass, String newPass) async {
    try {
          final response = await http.post(
      Uri.parse('$baseUrl/user/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPass,
          'new_password': newPass,
          'new_password_confirmation': newPass, // Tambahkan confirmation
        }),
      );
      
      print('Password update response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password berhasil diubah'};
      } else {
        try {
          final error = json.decode(response.body);
          return {'success': false, 'message': error['message'] ?? 'Gagal mengubah password'};
        } catch (e) {
          return {'success': false, 'message': 'Gagal mengubah password (Status: ${response.statusCode})'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  static Future<Map<String, dynamic>> bayarTagihanKeuangan(
    String token,
    String penghuniId, // Ubah ke String untuk char(30) di database
    int tagihanId, // Tambahkan kembali untuk update status tagihan
    int jumlah,
    String tanggal,
    {String keterangan = '', File? imageFile}
  ) async {
    try {
      // Debug: Print data yang akan dikirim
      print('=== DEBUG: Data yang dikirim ===');
      print('id_penghuni: $penghuniId (type: ${penghuniId.runtimeType})');
      print('tagihan_id: $tagihanId (type: ${tagihanId.runtimeType})');
      print('bayar: $jumlah (type: ${jumlah.runtimeType})');
      print('tgl_bayar: $tanggal (type: ${tanggal.runtimeType})');
      print('keterangan: $keterangan (type: ${keterangan.runtimeType})');
      print('================================');

      final url = '$baseUrl/keuangan';  // Kembali ke endpoint asli
      print('=== DEBUG: API URL ===');
      print('URL: $url');
      print('=====================');

      http.Response response;
      
      if (imageFile != null) {
        // Jika ada gambar, gunakan multipart request
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept'] = 'application/json';
        
        // Tambahkan field data
        request.fields['id_penghuni'] = penghuniId;
        request.fields['tagihan_id'] = tagihanId.toString();
        request.fields['bayar'] = jumlah.toString();
        request.fields['tgl_bayar'] = tanggal;
        request.fields['keterangan'] = keterangan;
        
        print('=== DEBUG: Multipart Fields ===');
        print('id_penghuni: ${request.fields['id_penghuni']}');
        print('tagihan_id: ${request.fields['tagihan_id']}');
        print('bayar: ${request.fields['bayar']}');
        print('tgl_bayar: ${request.fields['tgl_bayar']}');
        print('keterangan: ${request.fields['keterangan']}');
        print('==============================');
        
        // Tambahkan file gambar dengan nama field yang benar
        request.files.add(await http.MultipartFile.fromPath(
          'foto', // Nama field harus sama dengan yang diharapkan controller
          imageFile.path,
          filename: imageFile.path.split('/').last, // Tambahkan filename
        ));
        
        print('=== DEBUG: Multipart Request ===');
        print('Fields: ${request.fields}');
        print('Files: ${request.files.map((f) => '${f.field}: ${f.filename} (${f.length} bytes)').toList()}');
        print('File path: ${imageFile.path}');
        print('File exists: ${await imageFile.exists()}');
        print('File size: ${await imageFile.length()}');
        print('===============================');
        
        response = await http.Response.fromStream(await request.send());
      } else {
        // Jika tidak ada gambar, gunakan JSON request
        final requestBody = {
          'id_penghuni': penghuniId, // Sesuai nama field di database
          'tagihan_id': tagihanId, // Untuk update status tagihan
          'bayar': jumlah,
          'tgl_bayar': tanggal, // Sesuai nama field di database
          'keterangan': keterangan,
          'foto': null,
        };
        
        print('=== DEBUG: Request Body JSON ===');
        print(jsonEncode(requestBody));
        print('================================');

        response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(requestBody),
        );
      }

      // Debug: Print response
      print('=== DEBUG: Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=====================');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Pembayaran berhasil'};
      } else {
        try {
          final error = json.decode(response.body);
          String errorMessage = 'Pembayaran gagal';
          
          if (error is Map) {
            if (error['message'] != null) {
              errorMessage = error['message'];
            } else if (error['errors'] != null) {
              // Handle validation errors
              final errors = error['errors'] as Map;
              errorMessage = errors.values.first.toString();
            }
          }
          
          return {
            'success': false, 
            'message': errorMessage,
            'status_code': response.statusCode,
            'response_data': response.body
          };
        } catch (e) {
          return {
            'success': false, 
            'message': 'Pembayaran gagal (Status: ${response.statusCode})',
            'error': e.toString(),
            'response_body': response.body
          };
        }
      }
    } catch (e) {
      return {
        'success': false, 
        'message': 'Koneksi error: $e',
        'error_type': 'connection_error'
      };
    }
  }
}