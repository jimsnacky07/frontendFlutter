import 'package:flutter/material.dart';
import 'api_service.dart';

class LaporanPage extends StatefulWidget {
  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  Map<String, dynamic> reports = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  void fetchReports() async {
    try {
      // Simulasi data laporan karena endpoint belum dibuat
      await Future.delayed(Duration(seconds: 1));
      final data = {
        'total_penghuni': 15,
        'total_pendapatan': 12000000,
        'kamar_tersedia': 5,
        'kamar_terisi': 20,
        'laporan_bulanan': [
          {'bulan': 'Januari', 'pendapatan': 2000000, 'penghuni': 18},
          {'bulan': 'Februari', 'pendapatan': 1800000, 'penghuni': 16},
        ]
      };
      setState(() {
        reports = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching reports: $e');
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
            'Laporan',
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
                                        'Total Penghuni',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color: Color(0xFF5A6A73),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '${reports['total_penghuni'] ?? 0}',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: isSmallScreen ? 18 : 24,
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
                                        'Total Pendapatan',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color: Color(0xFF5A6A73),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Rp ${reports['total_pendapatan']?.toString().replaceAllMapped(RegExp(r"(\\d{1,3})(?=(\\d{3})+(?!\\d))"), (Match m) => "${m[1]}.")}',
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
                          ],
                        ),
                        // Laporan Bulanan
                        Text(
                          'Laporan Bulanan',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF18323A),
                          ),
                        ),
                        SizedBox(height: 16),
                        ...(reports['laporan_bulanan'] as List<dynamic>? ?? []).map((report) {
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
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Color(0xFFD1D2CD),
                                      radius: isSmallScreen ? 24 : 32,
                                      child: Icon(Icons.bar_chart, color: Color(0xFF5A6A73), size: isSmallScreen ? 24 : 32),
                                    ),
                                    SizedBox(width: isSmallScreen ? 12 : 24),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            report['bulan'] ?? 'No Title',
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
                                            'Pendapatan: Rp ${report['pendapatan']?.toString().replaceAllMapped(RegExp(r"(\\d{1,3})(?=(\\d{3})+(?!\\d))"), (Match m) => "${m[1]}.")}',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              fontSize: isSmallScreen ? 13 : 16,
                                              color: Color(0xFF5A6A73),
                                            ),
                                          ),
                                          Text(
                                            'Penghuni: ${report['penghuni'] ?? 0}',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              fontSize: isSmallScreen ? 13 : 16,
                                              color: Color(0xFF5A6A73),
                                            ),
                                          ),
                                        ],
                                      ),
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
}