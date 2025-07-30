import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'models.dart';

class PenghuniPage extends StatefulWidget {
  @override
  _PenghuniPageState createState() => _PenghuniPageState();
}

class _PenghuniPageState extends State<PenghuniPage> {
  List<Penghuni> residents = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchResidents();
  }

  void fetchResidents() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getUser();
      if (token == null || user == null) {
        setState(() {
          isLoading = false;
          errorMsg = 'Token atau user tidak ditemukan. Silakan login kembali.';
        });
        return;
      }

      final result = await ApiService.getPenghuniByUserId(token, user['id'].toString());
      print('API result: ' + result.toString());
      print('API data: ' + result['data'].toString());
      if (result['success']) {
        final data = result['data'];
        setState(() {
          residents = data is List
              ? data.map((e) => Penghuni.fromJson(e)).toList()
              : [Penghuni.fromJson(data)];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMsg = result['message'] ?? 'Gagal memuat data penghuni.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = 'Gagal memuat data penghuni.\n' + e.toString();
      });
      print('Error fetching residents: ' + e.toString());
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
            'Data Penghuni',
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
            ? Center(
                child: SpinKitFadingCircle(
                  color: Color(0xFF5A6A73),
                  size: 50.0,
                ),
              )
            : errorMsg != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 60),
                        SizedBox(height: 16),
                        Text(errorMsg!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.red)),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: Icon(Icons.refresh),
                          label: Text('Coba Lagi'),
                          onPressed: fetchResidents,
                        ),
                      ],
                    ),
                  )
                : residents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, color: Color(0xFF5A6A73), size: 60),
                            SizedBox(height: 16),
                            Text('Belum ada data penghuni',
                                style: TextStyle(fontSize: 18, color: Color(0xFF5A6A73))),
                          ],
                        ),
                      )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 400;
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 32, vertical: 24),
                    itemCount: residents.length,
                    itemBuilder: (context, index) {
                      final resident = residents[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 20),
                        color: Colors.white,
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
                                resident.nama,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: isSmallScreen ? 16 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF18323A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 12),
                              _buildInfoRow(Icons.person_pin_circle_outlined, resident.alamat, isSmallScreen),
                              _buildInfoRow(Icons.phone_iphone_outlined, resident.nohp, isSmallScreen),
                              _buildInfoRow(Icons.calendar_today_outlined, 'Registrasi: ${resident.registrasi}', isSmallScreen),
                              if (resident.kamar != null)
                                _buildInfoRow(Icons.king_bed_outlined, 'Kamar: ${resident.kamar!.id} (Lantai ${resident.kamar!.lantai})', isSmallScreen),
                              Divider(height: 32),
                              if (resident.keuangan.isNotEmpty) ...[
                                Text('Riwayat Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 13 : 16)),
                                SizedBox(height: 8),
                                ...resident.keuangan.map((k) => Text('- ${k.tglBayar}: Rp ${k.bayar} (${k.keterangan})', style: TextStyle(fontSize: isSmallScreen ? 12 : 15))),
                              ],
                              if (resident.tagihan.isNotEmpty) ...[
                                SizedBox(height: 16),
                                Text('Tagihan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 13 : 16)),
                                SizedBox(height: 8),
                                ...resident.tagihan.map((t) => Text('- ${t.bulan} ${t.tahun}: Rp ${t.tagihan} (${t.status})', style: TextStyle(fontSize: isSmallScreen ? 12 : 15))),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF5A6A73), size: isSmallScreen ? 16 : 18),
          SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: isSmallScreen ? 13 : 15))),
        ],
      ),
    );
  }
}