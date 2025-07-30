import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';
import 'auth_service.dart';

// Hapus class Penghuni dan Keuangan dari file ini, gunakan dari models.dart

class KeuanganPage extends StatefulWidget {
  @override
  _KeuanganPageState createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage> {
  Map<String, dynamic> finances = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFinances();
  }

  void fetchFinances() async {
    setState(() { isLoading = true; });
    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getUser();
      if (token == null || user == null) {
        setState(() { isLoading = false; });
        return;
      }
      
      // Ambil data penghuni yang sudah berhasil sebelumnya
      final result = await ApiService.getPenghuniByUserId(token, user['id'].toString());
      if (result['success']) {
        final penghuni = result['data'];
        final keuanganList = penghuni['keuangan'] as List<dynamic>? ?? [];
        
        setState(() {
          // Hitung saldo dengan cara yang lebih aman
          int totalSaldo = 0;
          for (var k in keuanganList) {
            // Pastikan k['bayar'] diubah ke int, karena bisa jadi double dari JSON
            totalSaldo += (k['bayar'] as num? ?? 0).toInt();
          }
          
          finances = {
            'saldo': totalSaldo,
            'transaksi': keuanganList.map((k) => {
              'tanggal': k['tgl_bayar'] ?? '',
              'keterangan': k['keterangan'] ?? '',
              'jumlah': (k['bayar'] as num? ?? 0).toInt(), // Juga pastikan jumlah di transaksi adalah int
              'tipe': 'pemasukan',
              // Hapus foto dari tampilan transaksi
            }).toList(),
          };
          isLoading = false;
        });
        
        // Debug: Print data transaksi
        print('=== DEBUG: Data Transaksi ===');
        for (int i = 0; i < finances['transaksi'].length; i++) {
          final transaksi = finances['transaksi'][i];
          print('Transaksi $i:');
          print('  - Tanggal: ${transaksi['tanggal']}');
          print('  - Keterangan: ${transaksi['keterangan']}');
          print('  - Jumlah: ${transaksi['jumlah']}');
        }
        print('============================');
      } else {
        setState(() { isLoading = false; });
      }
    } catch (e) {
      print('Error fetchFinances: $e');
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
            'Riwayat Transaksi',
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
                        // Saldo Card
                        Card(
                          color: Colors.white,
                          margin: EdgeInsets.only(bottom: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Saldo',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5A6A73),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Rp ${finances['saldo']?.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF18323A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Transaksi List
                        Text(
                          'Transaksi Terbaru',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF18323A),
                          ),
                        ),
                        SizedBox(height: 16),
                        ...(finances['transaksi'] as List<dynamic>? ?? []).map((transaction) {
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
                                          backgroundColor: transaction['tipe'] == 'pemasukan' ? Colors.green[100] : Colors.red[100],
                                          radius: isSmallScreen ? 24 : 32,
                                          child: Icon(
                                            transaction['tipe'] == 'pemasukan' ? Icons.arrow_upward : Icons.arrow_downward,
                                            color: transaction['tipe'] == 'pemasukan' ? Colors.green : Colors.red,
                                            size: isSmallScreen ? 24 : 32,
                                          ),
                                        ),
                                        SizedBox(width: isSmallScreen ? 12 : 24),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                transaction['keterangan'] ?? 'No Description',
                                                style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: isSmallScreen ? 15 : 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF18323A),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                transaction['tanggal'] ?? '',
                                                style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: isSmallScreen ? 12 : 14,
                                                  color: Color(0xFF5A6A73),
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Rp ${transaction['jumlah']?.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                                                style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: isSmallScreen ? 13 : 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: transaction['tipe'] == 'pemasukan' ? Colors.green : Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Hapus tampilan gambar di riwayat transaksi
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
}