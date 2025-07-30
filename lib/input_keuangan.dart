import 'package:flutter/material.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class InputKeuanganPage extends StatefulWidget {
  @override
  _InputKeuanganPageState createState() => _InputKeuanganPageState();
}

class _InputKeuanganPageState extends State<InputKeuanganPage> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  DateTime? _tanggal;
  bool _isLoading = false;
  File? _selectedImage; // Tambahkan untuk gambar
  final ImagePicker _picker = ImagePicker(); // Tambahkan image picker

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Input Pembayaran Manual',
          style: TextStyle(fontSize: 18),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Color(0xFF18323A),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Color(0xFFF6F5F3),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Jumlah field
                  Text(
                    'Jumlah',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A6A73),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _jumlahController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Masukkan jumlah pembayaran',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  SizedBox(height: 20),
                  
                  // Keterangan field
                  Text(
                    'Keterangan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A6A73),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _keteranganController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Masukkan keterangan pembayaran',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  SizedBox(height: 20),
                  
                  // Upload Bukti Pembayaran
                  Text(
                    'Bukti Pembayaran (Opsional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A6A73),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFDFE3E6)),
                    ),
                    child: Column(
                      children: [
                        if (_selectedImage != null) ...[
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Color(0xFFDFE3E6)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final XFile? image = await _picker.pickImage(
                                    source: ImageSource.camera,
                                    maxWidth: 1024,
                                    maxHeight: 1024,
                                    imageQuality: 80,
                                  );
                                  if (image != null) {
                                    setState(() {
                                      _selectedImage = File(image.path);
                                    });
                                  }
                                },
                                icon: Icon(Icons.camera_alt, size: 20),
                                label: Text('Kamera'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF18323A),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final XFile? image = await _picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 1024,
                                    maxHeight: 1024,
                                    imageQuality: 80,
                                  );
                                  if (image != null) {
                                    setState(() {
                                      _selectedImage = File(image.path);
                                    });
                                  }
                                },
                                icon: Icon(Icons.photo_library, size: 20),
                                label: Text('Galeri'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFF2994A),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedImage != null) ...[
                          SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            icon: Icon(Icons.delete, size: 16, color: Colors.red),
                            label: Text('Hapus Gambar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Tanggal field
                  Text(
                    'Pilih Tanggal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A6A73),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFDFE3E6)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Color(0xFF5A6A73)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _tanggal == null 
                              ? 'Pilih tanggal pembayaran' 
                              : 'Tanggal: ${_tanggal!.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              color: _tanggal == null ? Color(0xFF5A6A73) : Color(0xFF18323A),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => _tanggal = picked);
                          },
                          child: Text('Pilih Tanggal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF2994A),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF18323A),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading 
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate() || _tanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field wajib diisi!'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isLoading = true);
    final token = await AuthService.getToken();
    final user = await AuthService.getUser();
    if (token == null || user == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session habis, silakan login ulang.'), backgroundColor: Colors.red),
      );
      return;
    }
    
    // Ambil penghuni_id dari API untuk mendapatkan format yang benar
    String? penghuniId;
    final resultPenghuni = await ApiService.getPenghuniByUserId(token, user['id'].toString());
    if (resultPenghuni['success']) {
      final penghuni = resultPenghuni['data'];
      penghuniId = penghuni['id'].toString(); // Gunakan id penghuni (format PH001)
    } else {
      // Fallback ke user ID jika gagal
      penghuniId = user['id'].toString();
    }
    
    if (penghuniId == null || penghuniId.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ID penghuni tidak valid'), backgroundColor: Colors.red),
      );
      return;
    }
    
    print('=== DEBUG: Penghuni ID yang digunakan ===');
    print('Penghuni ID: $penghuniId');
    print('========================================');

    // Format tanggal untuk API (YYYY-MM-DD)
    final formattedDate = _tanggal!.toLocal().toString().split(' ')[0];
    print('=== DEBUG: Tanggal yang dikirim ===');
    print('Original date: $_tanggal');
    print('Formatted date: $formattedDate');
    print('===================================');

    final result = await ApiService.bayarTagihanKeuangan(
      token,
      penghuniId,
      0, // Untuk input manual, tagihan_id = 0 (tidak ada tagihan spesifik)
      int.tryParse(_jumlahController.text) ?? 0,
      formattedDate,
      keterangan: _keteranganController.text,
      imageFile: _selectedImage, // Kirim gambar jika ada
    );
    setState(() => _isLoading = false);
    if (result['success']) {
      Navigator.pop(context, true); // Kembali dan trigger refresh
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data keuangan berhasil disimpan!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal simpan data'), backgroundColor: Colors.red),
      );
    }
  }
} 