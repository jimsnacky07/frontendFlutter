import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'dashboard.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkBiometricAvailability() async {
    final isAvailable = await AuthService.isBiometricAvailable();
    final isEnabled = await AuthService.isBiometricLoginEnabled();
    print('=== BIOMETRIC CHECK ===');
    print('isAvailable: $isAvailable');
    print('isEnabled: $isEnabled');
    setState(() {
      _biometricAvailable = isAvailable;
      _biometricEnabled = isEnabled;
    });
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _handleBiometricLogin() async {
    print('=== BIOMETRIC LOGIN STARTED ===');
    setState(() {
      _isLoading = true;
    });

    try {
      print('Calling AuthService.authenticateWithBiometrics()...');
      // Langsung autentikasi dengan biometric tanpa pengecekan yang menghalangi
      final isAuthenticated = await AuthService.authenticateWithBiometrics();
      print('Authentication result: $isAuthenticated');
      
      if (!isAuthenticated) {
        // Jika autentikasi gagal, tampilkan dialog bantuan
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.fingerprint, color: Colors.orange),
                SizedBox(width: 8),
                Text('Autentikasi Sidik Jari Gagal'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Perangkat Anda menggunakan sensor sidik jari di tombol power',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Kemungkinan penyebab:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Sidik jari belum didaftarkan di pengaturan perangkat'),
                Text('• Posisi jari pada tombol power tidak tepat'),
                Text('• Sidik jari basah, kotor, atau terluka'),
                Text('• Sensor tombol power bermasalah'),
                Text('• Perangkat tidak mendukung'),
                SizedBox(height: 16),
                Text(
                  'Solusi:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Pastikan sidik jari sudah didaftarkan'),
                Text('• Coba scan dengan posisi jari yang berbeda'),
                Text('• Bersihkan jari dan tombol power'),
                Text('• Restart perangkat jika perlu'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  // Buka pengaturan fingerprint
                  try {
                    await launchUrl(
                      Uri.parse('android-app://com.android.settings/.security.settings.fingerprint.FingerprintSettings'),
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    // Fallback ke pengaturan umum
                    await launchUrl(
                      Uri.parse('android-app://com.android.settings/.Settings'),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                icon: Icon(Icons.settings),
                label: Text('Buka Pengaturan'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Reset biometric enabled status
                  AuthService.disableBiometricLogin();
                  setState(() {
                    _biometricEnabled = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Login sidik jari dinonaktifkan. Silakan login manual.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: Text('Nonaktifkan Sidik Jari'),
              ),
            ],
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Jika autentikasi berhasil tapi biometric belum diaktifkan, minta user untuk login manual
      if (!_biometricEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Autentikasi berhasil! Silakan login manual terlebih dahulu untuk mengaktifkan login sidik jari.'),
            backgroundColor: Colors.blue,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Ambil credentials yang tersimpan
      final credentials = await AuthService.getBiometricCredentials();
      if (credentials == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data login tidak ditemukan. Silakan login manual.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Login dengan credentials yang tersimpan
      final result = await ApiService.login(
        credentials['email'],
        credentials['password'],
      );

      if (result['success']) {
        await AuthService.saveUserSession(result['token'], result['user']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login dengan sidik jari berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainLayout()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login gagal. Silakan login manual.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error in biometric login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> result;
      
      if (_isLogin) {
        // Login process
        result = await ApiService.login(_emailController.text, _passwordController.text);
      } else {
        // Register process
        result = await ApiService.register(
          _nameController.text,
          _emailController.text,
          _phoneController.text,
          _passwordController.text,
        );
      }

      if (result['success']) {
        // Save user session if login
        if (_isLogin && result['token'] != null) {
          await AuthService.saveUserSession(result['token'], result['user']);
          
          // Tanya apakah ingin mengaktifkan login dengan sidik jari
          if (_biometricAvailable && !_biometricEnabled) {
            _showBiometricSetupDialog();
          }
        }
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLogin ? 'Login berhasil!' : result['message'] ?? 'Registrasi berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainLayout()),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Terjadi kesalahan. Silakan coba lagi.'),
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showBiometricSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aktifkan Login dengan Sidik Jari?'),
        content: Text('Apakah Anda ingin mengaktifkan login dengan sidik jari untuk kemudahan akses?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.enableBiometricLogin(
                _emailController.text,
                _passwordController.text,
              );
              setState(() {
                _biometricEnabled = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Login dengan sidik jari berhasil diaktifkan!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Aktifkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/kos.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Header
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Icon(
                                Icons.home,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Kos Management',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _isLogin ? 'Selamat datang kembali!' : 'Daftar akun baru',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32),
                        
                        // Biometric Login Button (hanya untuk login)
                        if (_isLogin) ...[
                          Container(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : () {
                                print('=== BIOMETRIC BUTTON CLICKED ===');
                                _handleBiometricLogin();
                              },
                              icon: Icon(Icons.fingerprint, color: Colors.white),
                              label: Text('Login dengan Sidik Jari'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF27AE60),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white54)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'atau',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.white54)),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],
                        
                        // Form
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Title
                                Text(
                                  _isLogin ? 'Login' : 'Registrasi',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF18323A),
                                    fontFamily: 'Roboto',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 24),
                                
                                // Name field (only for registration)
                                if (!_isLogin) ...[
                                  _buildTextField(
                                    controller: _nameController,
                                    label: 'Nama Lengkap',
                                    icon: Icons.person,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nama tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 16),
                                ],
                                
                                // Email field
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email tidak boleh kosong';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'Email tidak valid';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                
                                // Phone field (only for registration)
                                if (!_isLogin) ...[
                                  _buildTextField(
                                    controller: _phoneController,
                                    label: 'Nomor Telepon',
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nomor telepon tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 16),
                                ],
                                
                                // Password field
                                _buildPasswordField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  obscureText: _obscurePassword,
                                  onToggle: _togglePasswordVisibility,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password tidak boleh kosong';
                                    }
                                    if (!_isLogin && value.length < 6) {
                                      return 'Password minimal 6 karakter';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                
                                // Confirm Password field (only for registration)
                                if (!_isLogin) ...[
                                  _buildPasswordField(
                                    controller: _confirmPasswordController,
                                    label: 'Konfirmasi Password',
                                    obscureText: _obscureConfirmPassword,
                                    onToggle: _toggleConfirmPasswordVisibility,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Konfirmasi password tidak boleh kosong';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Password tidak cocok';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 16),
                                ],
                                
                                // Submit button
                                SizedBox(height: 8),
                                _buildSubmitButton(),
                                SizedBox(height: 16),
                                
                                // Toggle mode
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
                                      style: TextStyle(
                                        color: Color(0xFF5A6A73),
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _toggleMode,
                                      child: Text(
                                        _isLogin ? 'Daftar' : 'Login',
                                        style: TextStyle(
                                          color: Color(0xFF2D9CDB),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF5A6A73)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFDFE3E6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFDFE3E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2D9CDB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock, color: Color(0xFF5A6A73)),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: Color(0xFF5A6A73),
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFDFE3E6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFDFE3E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2D9CDB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2D9CDB),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: _isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: SpinKitFadingCircle(
                color: Colors.white,
                size: 20,
              ),
            )
          : Text(
              _isLogin ? 'Login' : 'Daftar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
    );
  }
} 