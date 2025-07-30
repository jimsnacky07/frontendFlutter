import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'models.dart';

class KamarPage extends StatefulWidget {
  @override
  _KamarPageState createState() => _KamarPageState();
}

class _KamarPageState extends State<KamarPage> {
  List<Kamar> rooms = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  void fetchRooms() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() {
          isLoading = false;
          errorMsg = 'Token tidak ditemukan. Silakan login kembali.';
        });
        return;
      }

      final result = await ApiService.getKamar(token);
      if (result['success']) {
        final List<dynamic> data = result['data'] ?? [];
      setState(() {
        rooms = data.map((e) => Kamar.fromJson(e)).toList();
        isLoading = false;
      });
      } else {
        setState(() {
          isLoading = false;
          errorMsg = result['message'] ?? 'Gagal memuat data kamar.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = 'Gagal memuat data kamar.\nCek koneksi atau server Anda.';
      });
      print('Error fetching rooms: $e');
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
            'Data Kamar',
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
                          onPressed: fetchRooms,
                        ),
                      ],
                    ),
                  )
                : rooms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hotel, color: Color(0xFF5A6A73), size: 60),
                            SizedBox(height: 16),
                            Text('Belum ada data kamar',
                                style: TextStyle(fontSize: 18, color: Color(0xFF5A6A73))),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmallScreen = constraints.maxWidth < 400;
                          return ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 32, vertical: 24),
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              final room = rooms[index];
                              return Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  child: Card(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 4,
                                    child: Padding(
                                      padding: EdgeInsets.all(isSmallScreen ? 12 : 24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: Color(0xFF2D9CDB).withOpacity(0.15),
                                                radius: isSmallScreen ? 24 : 36,
                                                child: Icon(Icons.king_bed_outlined, color: Color(0xFF2D9CDB), size: isSmallScreen ? 24 : 36),
                                              ),
                                              SizedBox(width: isSmallScreen ? 12 : 24),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            room.id,
                                                            style: TextStyle(
                                                              fontFamily: 'Roboto',
                                                              fontSize: isSmallScreen ? 16 : 22,
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF18323A),
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.green[100],
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: Text(
                                                            'Lantai ${room.lantai}',
                                                            style: TextStyle(
                                                              color: Colors.green[900],
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: isSmallScreen ? 12 : 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.people_outline, color: Color(0xFF5A6A73), size: 18),
                                                        SizedBox(width: 6),
                                                        Text('Kapasitas: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                                        Text(room.kapasitas, style: TextStyle(fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                    SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.checklist_rtl, color: Color(0xFF5A6A73), size: 18),
                                                        SizedBox(width: 6),
                                                        Text('Fasilitas: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                                        Expanded(child: Text(room.fasilitas, style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                                      ],
                                                    ),
                                                    SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.attach_money, color: Color(0xFF5A6A73), size: 18),
                                                        SizedBox(width: 6),
                                                        Text('Tarif: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                                        Text('Rp ${room.tarif.toString().replaceAllMapped(RegExp(r"(\\d{1,3})(?=(\\d{3})+(?!\\d))"), (Match m) => "${m[1]}.")}', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF2994A))),
                                                      ],
                                                    ),
                                                    SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.group, color: Color(0xFF5A6A73), size: 18),
                                                        SizedBox(width: 6),
                                                        Text('Max Penghuni: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                                        Text('${room.maxPenghuni}', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      ],
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
                            },
                          );
                        },
                      ),
      ),
    );
  }
}