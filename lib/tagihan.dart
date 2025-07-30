import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';
import 'auth_service.dart';
import 'pembayaran_sukses.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class TagihanPage extends StatefulWidget {
  @override
  _TagihanPageState createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
  Map<String, dynamic> bills = {};
  bool isLoading = true;
  Penghuni? penghuni;

  @override
  void initState() {
    super.initState();
    fetchBills();
  }

  void fetchBills() async {
    setState(() { isLoading = true; });
    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getUser();
      if (token == null || user == null) {
        setState(() { isLoading = false; });
        return;
      }
      final result = await ApiService.getPenghuniByUserId(token, user['id'].toString());
      if (result['success']) {
        penghuni = Penghuni.fromJson(result['data']);
        setState(() {
          bills = {
            'total_tagihan': penghuni?.tagihan.fold(0, (sum, t) => sum + t.tagihan) ?? 0,
            'tagihan_belum_lunas': penghuni?.tagihan.where((t) => t.status != 'Lunas').fold(0, (sum, t) => sum + t.tagihan) ?? 0,
            'daftar_tagihan': penghuni?.tagihan.map((t) => {
              'id': t.id,
              'bulan': t.bulan,
              'tahun': t.tahun,
              'jumlah': t.tagihan,
              'status': t.status,
            }).toList() ?? [],
          };
          isLoading = false;
        });
      } else {
        setState(() { isLoading = false; });
      }
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F5F3),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFDFE3E6), width: 2),
            ),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Tagihan',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A6A73),
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
      body: Container(
        color: Color(0xFFF6F5F3),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 400;
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 32, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: Colors.white,
                                margin: EdgeInsets.only(bottom: 20, right: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 3,
                                child: Padding(
                                  padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Tagihan',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color: Color(0xFF5A6A73),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Rp ${bills['total_tagihan']?.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: isSmallScreen ? 16 : 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF18323A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                color: Colors.white,
                                margin: EdgeInsets.only(bottom: 20, left: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 3,
                                child: Padding(
                                  padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Belum Lunas',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color: Color(0xFF5A6A73),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Rp ${bills['tagihan_belum_lunas']?.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: isSmallScreen ? 16 : 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Daftar Tagihan
                        Text(
                          'Daftar Tagihan',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF18323A),
                          ),
                        ),
                        SizedBox(height: 16),
                        ...(bills['daftar_tagihan'] as List<dynamic>? ?? []).map((bill) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: Card(
                              color: Colors.white,
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: EdgeInsets.all(isSmallScreen ? 12 : 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: bill['status'] == 'Lunas' ? Colors.green[100] : Colors.red[100],
                                          radius: isSmallScreen ? 24 : 32,
                                          child: Icon(
                                            bill['status'] == 'Lunas' ? Icons.check_circle : Icons.warning,
                                            color: bill['status'] == 'Lunas' ? Colors.green : Colors.red,
                                            size: isSmallScreen ? 24 : 32,
                                          ),
                                        ),
                                        SizedBox(width: isSmallScreen ? 12 : 24),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${bill['bulan']} ${bill['tahun']}',
                                                style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: isSmallScreen ? 15 : 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF18323A),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Rp ${bill['jumlah']?.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                                                style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: isSmallScreen ? 14 : 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: bill['status'] == 'Lunas' ? Colors.green : Colors.red,
                                                ),
                                              ),
                                              Text(
                                                'Status: ${bill['status'] ?? ''}',
                                                style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: isSmallScreen ? 12 : 14,
                                                  color: bill['status'] == 'Lunas' ? Colors.green : Colors.red,
                                                ),
                                              ),
                                              if (bill['status'] == 'Belum Lunas')
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 12.0),
                                                  child: ElevatedButton(
                                                    onPressed: () => _bayarTagihan(bill),
                                                    child: Text('Bayar'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Color(0xFF2D9CDB),
                                                      foregroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _bayarTagihan(Map bill) async {
    // Tampilkan dialog input manual sebelum bayar
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _InputKeuanganDialog(
        jumlahTagihan: bill['tagihan'] ?? bill['jumlah'] ?? 0, // Ambil jumlah dari tagihan
      ),
    );
    if (result == null) return; // batal
    setState(() { isLoading = true; });
    final token = await AuthService.getToken();
    final user = await AuthService.getUser();
    if (token == null || user == null || penghuni == null) {
      setState(() { isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session habis, silakan login ulang.'), backgroundColor: Colors.red),
      );
      return;
    }
    
    final jumlah = result['jumlah'];
    final tanggalBayar = result['tanggal'];
    final keterangan = result['keterangan'];
    
    // Debug: Print data penghuni
    print('=== DEBUG: Data penghuni untuk pembayaran ===');
    print('Penghuni ID: ${penghuni!.id}');
    print('User ID: ${user['id']}');
    print('Bill ID: ${bill['id']}');
    print('Tanggal Bayar: $tanggalBayar');
    print('Jumlah: $jumlah');
    print('Keterangan: $keterangan');
    print('=============================================');
    
    // Ambil penghuni_id dari API untuk mendapatkan format yang benar
    String? penghuniId;
    try {
      final penghuniData = await ApiService.getPenghuniByUserId(token, user['id'].toString());
      if (penghuniData['success']) {
        final data = penghuniData['data'];
        penghuniId = data['id'].toString(); // Gunakan id penghuni (format PH001)
      }
    } catch (e) {
      print('Error getting penghuni data: $e');
    }
    
    // Fallback ke user ID jika tidak ada
    if (penghuniId == null || penghuniId.isEmpty) {
      penghuniId = user['id'].toString();
    }
    
    if (penghuniId == null || penghuniId.isEmpty) {
      setState(() { isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ID penghuni tidak valid'), backgroundColor: Colors.red),
      );
      return;
    }
    
    final bayarResult = await ApiService.bayarTagihanKeuangan(
      token,
      penghuniId,
      bill['id'], // Tambahkan ID tagihan untuk update status
      jumlah,
      tanggalBayar,
      keterangan: keterangan,
      imageFile: result['image'], // Kirim gambar jika ada
    );
    setState(() { isLoading = false; });
    
    if (bayarResult['success']) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PembayaranSuksesPage(
            message: bayarResult['message'] ?? 'Pembayaran berhasil!',
            detail: {
              'Tagihan ID': bill['id'],
              'Jumlah': jumlah,
              'Tanggal': tanggalBayar,
            },
          ),
        ),
      );
      fetchBills();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bayarResult['message'] ?? 'Pembayaran gagal!'), backgroundColor: Colors.red),
      );
    }
  }
}

// Dialog input manual keuangan
class _InputKeuanganDialog extends StatefulWidget {
  final int jumlahTagihan; // Tambahkan parameter jumlah tagihan
  
  const _InputKeuanganDialog({required this.jumlahTagihan});
  
  @override
  State<_InputKeuanganDialog> createState() => _InputKeuanganDialogState();
}

class _InputKeuanganDialogState extends State<_InputKeuanganDialog> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  DateTime? _tanggal;
  File? _selectedImage; // Tambahkan untuk gambar
  final ImagePicker _picker = ImagePicker(); // Tambahkan image picker

  @override
  void initState() {
    super.initState();
    // Isi otomatis jumlah dengan jumlah tagihan
    _jumlahController.text = widget.jumlahTagihan.toString();
    // Set tanggal default ke hari ini
    _tanggal = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
                    return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                      maxWidth: MediaQuery.of(context).size.width * 0.95,
                    ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                                    // Header
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xFF18323A),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.payment, color: Colors.white, size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Input Pembayaran Manual',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
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
                                                                    Column(
                                          children: [
                                            SizedBox(
                                              width: double.infinity,
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
                                                label: Text('Kamera', style: TextStyle(fontSize: 12)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(0xFF18323A),
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(vertical: 8),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            SizedBox(
                                              width: double.infinity,
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
                                                label: Text('Galeri', style: TextStyle(fontSize: 12)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(0xFFF2994A),
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(vertical: 8),
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
                                label: Text('Hapus Gambar', style: TextStyle(color: Colors.red, fontSize: 12)),
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
                              child: Text('Pilih Tanggal', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFF2994A),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Actions
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF6F5F3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal'),
                      style: TextButton.styleFrom(
                        foregroundColor: Color(0xFF5A6A73),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF18323A),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
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
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate() || _tanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field wajib diisi!'), backgroundColor: Colors.red),
      );
      return;
    }
    
    Navigator.pop(context, {
      'jumlah': int.tryParse(_jumlahController.text) ?? 0,
      'tanggal': _tanggal!.toLocal().toString().split(' ')[0],
      'keterangan': _keteranganController.text,
      'image': _selectedImage, // Tambahkan gambar ke data yang dikembalikan
    });
  }
}