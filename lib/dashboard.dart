import 'package:flutter/material.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'models.dart';
import 'keuangan.dart'; // hanya untuk navigasi halaman, bukan model
import 'tagihan.dart'; // hanya untuk navigasi halaman, bukan model
import 'penghuni.dart';
import 'laporan.dart';
import 'layouts.dart';
import 'welcome.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Tambahkan stub jika belum ada di ApiService
// static Future<Map<String, dynamic>> getPenghuniByUserId(String token, String userId) async {
//   final response = await http.get(
//     Uri.parse('$baseUrl/penghuni/user/$userId'),
//     headers: {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       'Authorization': 'Bearer $token',
//     },
//   );
//   if (response.statusCode == 200) {
//     final data = json.decode(response.body);
//     return {'success': true, 'data': data['data']};
//   } else {
//     return {'success': false, 'message': 'Gagal mengambil data penghuni'};
//   }
// }

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Penghuni? penghuni;
  bool isLoading = true;
  String? errorMsg;
  int saldo = 0; // Dummy saldo, bisa diisi dari relasi keuangan jika mau
  List<String> kamarImages = [];
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    fetchPenghuniForUser();
    kamarImages = List.generate(5, (i) => 'asset/kamar0${i + 1}.jpg');
    fetchUser();
  }

  void fetchPenghuniForUser() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getUser(); // Ambil user dari session
      if (token == null || user == null) {
        setState(() {
          isLoading = false;
          errorMsg = 'User belum login.';
        });
        return;
      }
      // Ambil data penghuni berdasarkan user_id
      final result = await ApiService.getPenghuniByUserId(token, user['id'].toString());
      print('API result dashboard: ' + result.toString());
      print('API data dashboard: ' + result['data'].toString());
      if (result['success']) {
        setState(() {
          penghuni = Penghuni.fromJson(result['data']);
          isLoading = false;
        }
        );
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
      print('Error fetching penghuni dashboard: ' + e.toString());
    }
  }

  void fetchUser() async {
    final u = await AuthService.getUser();
    setState(() { user = u; });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    return Scaffold(
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
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5A6A73))),
              IconButton(
                icon: Icon(Icons.account_circle, color: Color(0xFF5A6A73), size: 32),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => _ProfileDialog(user: user, penghuni: penghuni),
                  );
                },
                tooltip: 'Profil',
              ),
            ],
          ),
        ),
      ),
      body: isLoading
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
                        onPressed: () {},
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Header dengan gambar dan overlay + saldo
                    Stack(
                      children: [
                        ClipPath(
                          clipper: _HeaderClipper(),
                          child: Image.asset(
                            'asset/kos.jpg',
                            height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.20 : 0.25),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: isSmallScreen ? 8 : 32,
                          top: isSmallScreen ? 50 : 60,
                          right: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Color(0xFF18323A),
                                    radius: isSmallScreen ? 20 : 28,
                                    child: Icon(Icons.account_balance_wallet, color: Colors.white, size: isSmallScreen ? 22 : 32),
                                  ),
                                  SizedBox(width: isSmallScreen ? 8 : 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                        Text('Hai, ${penghuni?.nama ?? ''}', style: TextStyle(fontSize: isSmallScreen ? 13 : 16, color: Colors.white, fontFamily: 'Roboto')),
                                        Text(_getGreeting(), style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.white70, fontFamily: 'Roboto')),
                                      ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 10 : 16),
                    // Barisan horizontal gambar kamar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kamar',
                              style: TextStyle(
                                  fontSize: isSmallScreen ? 18 : 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF18323A),
                                  fontFamily: 'Roboto')),
                          Container(
                            margin: EdgeInsets.only(top: 2, bottom: isSmallScreen ? 8 : 16),
                            height: 2,
                            width: 80,
                            color: Color(0xFFDFE3E6),
                          ),
                          kamarImages.isEmpty
                              ? Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.hotel, color: Color(0xFF5A6A73), size: isSmallScreen ? 40 : 60),
                                      SizedBox(height: 16),
                                      Text('Belum ada gambar kamar',
                                          style: TextStyle(fontSize: isSmallScreen ? 14 : 18, color: Color(0xFF5A6A73))),
                                    ],
                                  ),
                                )
                              : Container(
                                  height: isSmallScreen ? 90 : 140,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: kamarImages.length,
                                    itemBuilder: (context, i) {
                                      return Container(
                                        width: isSmallScreen ? screenWidth * 0.5 : 200,
                                        margin: EdgeInsets.only(right: isSmallScreen ? 8 : 16),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: Image.asset(
                                                kamarImages[i],
                                                height: isSmallScreen ? 90 : 140,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              left: 12,
                                              bottom: 12,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Kamar 0${i + 1}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: isSmallScreen ? 12 : 16,
                                                    fontFamily: 'Roboto',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 18 : 32),
                    // Section Akses Cepat
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Akses Cepat',
                                  style: TextStyle(
                                      fontSize: isSmallScreen ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF18323A),
                                      fontFamily: 'Roboto')),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 2, bottom: isSmallScreen ? 8 : 16),
                            height: 2,
                            width: 80,
                            color: Color(0xFFDFE3E6),
                          ),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 500),
                            child: isSmallScreen
                                ? GridView.count(
                                    crossAxisCount: 2,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    children: [
                                      _QuickAccessButton(
                                        icon: Icons.history_edu_outlined,
                                        label: 'Riwayat Transaksi',
                                        color: Color(0xFF2D9CDB),
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => KeuanganPage()));
                                        },
                                      ),
                                      _QuickAccessButton(
                                        icon: Icons.receipt_long_outlined,
                                        label: 'Tagihan',
                                        color: Color(0xFFF2994A),
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => TagihanPage()));
                                        },
                                      ),
                                      _QuickAccessButton(
                                        icon: Icons.groups_outlined,
                                        label: 'Penghuni',
                                        color: Color(0xFF27AE60),
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => PenghuniPage()));
                                        },
                                      ),
                                      _QuickAccessButton(
                                        icon: Icons.help_outline,
                                        label: 'Bantuan',
                                        color: Color(0xFF9B51E0),
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => LayoutsPage()));
                                        },
                                      ),
                                    ],
                                  )
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        _QuickAccessButton(
                                          icon: Icons.history_edu_outlined,
                                          label: 'Riwayat Transaksi',
                                          color: Color(0xFF2D9CDB),
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => KeuanganPage()));
                                          },
                                        ),
                                        SizedBox(width: 16),
                                        _QuickAccessButton(
                                          icon: Icons.receipt_long_outlined,
                                          label: 'Tagihan',
                                          color: Color(0xFFF2994A),
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => TagihanPage()));
                                          },
                                        ),
                                        SizedBox(width: 16),
                                        _QuickAccessButton(
                                          icon: Icons.groups_outlined,
                                          label: 'Penghuni',
                                          color: Color(0xFF27AE60),
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => PenghuniPage()));
                                          },
                                        ),
                                        SizedBox(width: 16),
                                        _QuickAccessButton(
                                          icon: Icons.help_outline,
                                          label: 'Bantuan',
                                          color: Color(0xFF9B51E0),
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => LayoutsPage()));
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    // Section History Pembayaran (pindah ke posisi keuangan, hapus keuangan)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('History Pembayaran',
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5A6A73),
                                  fontFamily: 'Roboto')),
                          SizedBox(height: 4),
                          Text('Riwayat',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF7B7B7B),
                                  fontFamily: 'Roboto')),
                          SizedBox(height: 24),
                          Center(
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _StatBox(label: 'Sudah', value: '${penghuni?.keuangan.length ?? 0}', sub: 'pembayaran'),
                                      VerticalDivider(thickness: 1, color: Color(0xFFDFE3E6), width: 32),
                                      _StatBox(label: 'Total', value: '${penghuni?.tagihan.length ?? 0}', sub: 'tagihan'),
                                      VerticalDivider(thickness: 1, color: Color(0xFFDFE3E6), width: 32),
                                      _StatBox(label: 'Belum', value: '${penghuni != null ? penghuni!.tagihan.where((t) => t.status != 'Lunas').length : 0}', sub: 'belum lunas'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    // Section Aturan
                    Material(
                      color: Color(0xFF18323A),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomePage()));
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 48, horizontal: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Aturan',
                                  style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Roboto')),
                              SizedBox(height: 24),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _RuleBox(title: 'Aturan 1', desc: 'Pembayaran Sewa:\n• Pembayaran sewa harus dilakukan setiap bulan sebelum tanggal jatuh tempo yang telah ditentukan.\n• Keterlambatan pembayaran lebih dari [jumlah hari tertentu] dapat dikenakan denda sebesar [jumlah tertentu].'),
                                    SizedBox(width: 16),
                                    _RuleBox(title: 'Aturan 2', desc: 'Kebersihan dan Kerapihan:\n• Setiap penghuni wajib menjaga kebersihan dan kerapihan kamar dan area bersama.'),
                                    SizedBox(width: 16),
                                    _RuleBox(title: 'Aturan 3', desc: 'Tamu:\n• Tamu hanya diperbolehkan berkunjung pada jam yang telah ditentukan oleh pengelola.\n• Penghuni bertanggung jawab atas perilaku tamunya.'),
                                    SizedBox(width: 16),
                                    _RuleBox(title: 'Aturan 4', desc: 'Keamanan:\n• Setiap penghuni wajib menjaga keamanan barang pribadi dan tidak meninggalkan barang berharga di area umum.'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12),
                              Text('(Klik area ini untuk melihat syarat & ketentuan lengkap)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Footer
                    Container(
                      width: double.infinity,
                      color: Color(0xFF18323A),
                      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Footer',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Roboto')),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Home', style: TextStyle(color: Colors.white)),
                                  Text('Benefits', style: TextStyle(color: Colors.white)),
                                  Text('Reviews', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SHIPPING & RETURNS', style: TextStyle(color: Colors.white)),
                                  Text('STORE POLICY', style: TextStyle(color: Colors.white)),
                                  Text('PAYMENT METHODS', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('FAQ', style: TextStyle(color: Colors.white)),
                                  Text('INSTAGRAM', style: TextStyle(color: Colors.white)),
                                  Text('YOUTUBE', style: TextStyle(color: Colors.white)),
                                  Text('TWITTER', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Center(
                            child: Text('copy rights', style: TextStyle(color: Colors.white70)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    ); // <- Tambahkan kurung tutup untuk Scaffold
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String route;
  final IconData icon;

  DashboardCard({required this.title, required this.route, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value, sub;
  const _StatBox({required this.label, required this.value, required this.sub});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFFF6F5F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, style: TextStyle(color: Color(0xFF5A6A73), fontSize: 18, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 8),
        Text(value, style: TextStyle(color: Color(0xFF18323A), fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Roboto')),
        SizedBox(height: 4),
        Text(sub, style: TextStyle(color: Color(0xFF7B7B7B), fontSize: 14, fontFamily: 'Roboto')),
      ],
    );
  }
}

class _RuleBox extends StatelessWidget {
  final String title, desc;
  const _RuleBox({required this.title, required this.desc});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Roboto')),
          SizedBox(height: 8),
          Text(desc, style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Roboto')),
        ],
      ),
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAccessButton({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 36),
            ),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, color: color, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _ProfileDialog extends StatelessWidget {
  final Map<String, dynamic>? user;
  final Penghuni? penghuni;
  const _ProfileDialog({this.user, this.penghuni});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user?['foto'] != null)
              Center(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user!['foto']),
                  radius: 40,
                ),
              ),
            SizedBox(height: 12),
            _profileRow('ID User', user?['id']?.toString() ?? '-'),
            _profileRow('ID Penghuni', penghuni?.id ?? '-'),
            _profileRow('Nama Penghuni', penghuni?.nama ?? '-'),
            _profileRow('Email', user?['email'] ?? '-'),
            SizedBox(height: 8),
            _profileRow('Password', '********'),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.lock_reset),
                label: Text('Ubah Password'),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => _ChangePasswordDialog(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D9CDB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.fingerprint),
                label: Text('Kelola Login Sidik Jari'),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => _BiometricSettingsDialog(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Tutup'),
        ),
      ],
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Ubah Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _oldPassController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password Lama'),
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _newPassController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password Baru'),
              validator: (v) => v == null || v.length < 6 ? 'Min 6 karakter' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _confirmPassController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Konfirmasi Password Baru'),
              validator: (v) => v != _newPassController.text ? 'Tidak cocok' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleChangePassword,
          child: _isLoading ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Simpan'),
        ),
      ],
    );
  }

  void _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });
    final token = await AuthService.getToken();
    if (token == null) {
      setState(() { _isLoading = false; });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session habis, silakan login ulang.'), backgroundColor: Colors.red),
      );
      return;
    }
    final result = await ApiService.ubahPassword(
      token,
      _oldPassController.text,
      _newPassController.text,
    );
    setState(() { _isLoading = false; });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message']), backgroundColor: result['success'] ? Colors.green : Colors.red),
    );
  }
}

class _BiometricSettingsDialog extends StatefulWidget {
  @override
  State<_BiometricSettingsDialog> createState() => _BiometricSettingsDialogState();
}

class _BiometricSettingsDialogState extends State<_BiometricSettingsDialog> {
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  void _checkBiometricStatus() async {
    final isAvailable = await AuthService.isBiometricAvailable();
    final isEnabled = await AuthService.isBiometricLoginEnabled();
    setState(() {
      _biometricAvailable = isAvailable;
      _biometricEnabled = isEnabled;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Pengaturan Login Sidik Jari'),
      content: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_biometricAvailable) ...[
                  Icon(Icons.error_outline, color: Colors.red, size: 40),
                  SizedBox(height: 8),
                  Text(
                    'Perangkat tidak mendukung login dengan sidik jari',
                    style: TextStyle(color: Colors.red),
                  ),
                ] else ...[
                  Icon(
                    _biometricEnabled ? Icons.fingerprint : Icons.fingerprint_outlined,
                    color: _biometricEnabled ? Colors.green : Colors.grey,
                    size: 40,
                  ),
                  SizedBox(height: 8),
                  Text(
                    _biometricEnabled
                        ? 'Login dengan sidik jari aktif'
                        : 'Login dengan sidik jari tidak aktif',
                    style: TextStyle(
                      color: _biometricEnabled ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Login dengan sidik jari memungkinkan Anda masuk ke aplikasi tanpa memasukkan email dan password.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Tutup'),
        ),
        if (_biometricAvailable) ...[
          if (_biometricEnabled)
            ElevatedButton(
              onPressed: () async {
                await AuthService.disableBiometricLogin();
                setState(() {
                  _biometricEnabled = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Login dengan sidik jari berhasil dinonaktifkan'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Nonaktifkan'),
            )
          else
            ElevatedButton(
              onPressed: () async {
                // Minta user untuk login ulang untuk mengaktifkan biometric
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => _EnableBiometricDialog(),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Aktifkan'),
            ),
        ],
      ],
    );
  }
}

class _EnableBiometricDialog extends StatefulWidget {
  @override
  State<_EnableBiometricDialog> createState() => _EnableBiometricDialogState();
}

class _EnableBiometricDialogState extends State<_EnableBiometricDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Aktifkan Login Sidik Jari'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Masukkan email dan password Anda untuk mengaktifkan login dengan sidik jari',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleEnableBiometric,
          child: _isLoading ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Aktifkan'),
        ),
      ],
    );
  }

  void _handleEnableBiometric() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() { _isLoading = true; });
    
    try {
      // Verifikasi login
      final result = await ApiService.login(_emailController.text, _passwordController.text);
      
      if (result['success']) {
        // Aktifkan biometric login
        await AuthService.enableBiometricLogin(_emailController.text, _passwordController.text);
        
        Navigator.pop(context); // Tutup dialog enable
        Navigator.pop(context); // Tutup dialog settings
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login dengan sidik jari berhasil diaktifkan!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email atau password salah'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }
}