import 'package:flutter/material.dart';
import 'admin.dart';
import 'auth_service.dart';
import 'dashboard.dart';
import 'kamar.dart';
import 'keuangan.dart';
import 'laporan.dart';
import 'login.dart';
import 'penghuni.dart';
import 'tagihan.dart';
import 'welcome.dart';
import 'layouts.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kos Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isLoggedIn ? MainLayout() : LoginPage();
  }
}

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  Widget _currentPage = DashboardPage();

  void _navigateTo(Widget page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    return Scaffold(
      backgroundColor: Color(0xFFF6F5F3),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isSmallScreen ? 110 : 70),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFDFE3E6), width: 2),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isSmallScreen ? 8 : 0),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFFD1D2CD),
                    radius: 24,
                    child: Icon(Icons.home, color: Color(0xFF5A6A73), size: 32),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 8 : 0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _NavButton(label: 'Beranda', onTap: () => _navigateTo(DashboardPage())),
                    SizedBox(width: 16),
                    _NavButton(label: 'Kamar', onTap: () => _navigateTo(KamarPage())),
                    SizedBox(width: 16),
                    _NavButton(label: 'Syarat & Ketentuan', onTap: () => _navigateTo(WelcomePage())),
                    SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LayoutsPage()),
                        );
                      },
                      child: Text(
                        'Bantuan ?',
                        style: TextStyle(
                          color: Color(0xFF5A6A73),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await AuthService.logout();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      icon: Icon(Icons.person, size: 18, color: Colors.white),
                      label: Text('Log Out', style: TextStyle(color: Colors.white, fontFamily: 'Roboto')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF18323A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(child: _currentPage),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: Color(0xFF18323A),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
