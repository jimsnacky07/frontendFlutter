import 'package:flutter/material.dart';
import 'keuangan.dart';
import 'tagihan.dart';
import 'penghuni.dart';
import 'laporan.dart';
import 'welcome.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return SingleChildScrollView(
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
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 32,
                top: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFF18323A),
                          radius: 28,
                          child: Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Saldo', style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Roboto')),
                            Row(
                              children: [
                                Text('Rp 2.500.000', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Roboto')),
                                SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFF2994A),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    elevation: 0,
                                  ),
                                  child: Text('Top Up', style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Perlu',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B8572),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Diingat !!!\nkos perlu dibayar',
                      style: TextStyle(
                        fontSize: 22,
                        color: Color(0xFF5A6A73),
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          // Section Akses Cepat
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Akses Cepat',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF18323A),
                            fontFamily: 'Roboto')),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 2, bottom: 16),
                  height: 2,
                  width: 80,
                  color: Color(0xFFDFE3E6),
                ),
                isWide
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _QuickAccessButton(
                            icon: Icons.attach_money,
                            label: 'Keuangan',
                            color: Color(0xFF2D9CDB),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => KeuanganPage()));
                            },
                          ),
                          _QuickAccessButton(
                            icon: Icons.receipt,
                            label: 'Tagihan',
                            color: Color(0xFFF2994A),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TagihanPage()));
                            },
                          ),
                          _QuickAccessButton(
                            icon: Icons.people,
                            label: 'Penghuni',
                            color: Color(0xFF27AE60),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PenghuniPage()));
                            },
                          ),
                          _QuickAccessButton(
                            icon: Icons.report,
                            label: 'Laporan',
                            color: Color(0xFF9B51E0),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => LaporanPage()));
                            },
                          ),
                        ],
                      )
                    : GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _QuickAccessButton(
                            icon: Icons.attach_money,
                            label: 'Keuangan',
                            color: Color(0xFF2D9CDB),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => KeuanganPage()));
                            },
                          ),
                          _QuickAccessButton(
                            icon: Icons.receipt,
                            label: 'Tagihan',
                            color: Color(0xFFF2994A),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TagihanPage()));
                            },
                          ),
                          _QuickAccessButton(
                            icon: Icons.people,
                            label: 'Penghuni',
                            color: Color(0xFF27AE60),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PenghuniPage()));
                            },
                          ),
                          _QuickAccessButton(
                            icon: Icons.report,
                            label: 'Laporan',
                            color: Color(0xFF9B51E0),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => LaporanPage()));
                            },
                          ),
                        ],
                      ),
              ],
            ),
          ),
          SizedBox(height: 32),
          // Grid gambar kamar dengan deskripsi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: List.generate(5, (i) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'asset/kamar0${i + 1}.jpg',
                        height: 140,
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
                            fontSize: 16,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatBox(
                            label: 'Sudah',
                            value: '20',
                            sub: 'kamar',
                          ),
                          Container(
                            width: 1,
                            height: 48,
                            color: Color(0xFFDFE3E6),
                          ),
                          _StatBox(
                            label: 'Total',
                            value: '25',
                            sub: 'kamar',
                          ),
                          Container(
                            width: 1,
                            height: 48,
                            color: Color(0xFFDFE3E6),
                          ),
                          _StatBox(
                            label: 'Belum',
                            value: '5',
                            sub: 'kamar',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          // Section Aturan
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomePage()));
            },
            child: Container(
              width: double.infinity,
              color: Color(0xFF18323A),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _RuleBox(title: 'Aturan 1', desc: 'Pembayaran Sewa:\n• Pembayaran sewa harus dilakukan setiap bulan sebelum tanggal jatuh tempo yang telah ditentukan.\n• Keterlambatan pembayaran lebih dari [jumlah hari tertentu] dapat dikenakan denda sebesar [jumlah tertentu].'),
                      _RuleBox(title: 'Aturan 2', desc: 'Kebersihan dan Kerapihan:\n• Setiap penghuni wajib menjaga kebersihan dan kerapihan kamar dan area bersama.'),
                      _RuleBox(title: 'Aturan 3', desc: 'Tamu:\n• Tamu hanya diperbolehkan berkunjung pada jam yang telah ditentukan oleh pengelola.\n• Penghuni bertanggung jawab atas perilaku tamunya.'),
                      _RuleBox(title: 'Aturan 4', desc: 'Keamanan:\n• Setiap penghuni wajib menjaga keamanan barang pribadi dan tidak meninggalkan barang berharga di area umum.'),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('(Klik area ini untuk melihat syarat & ketentuan lengkap)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
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
    );
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
    return InkWell(
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