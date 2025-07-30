import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricCredentialsKey = 'biometric_credentials';

  static final LocalAuthentication _localAuth = LocalAuthentication();

  // Save user session
  static Future<void> saveUserSession(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(user));
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return json.decode(userString);
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Clear user session (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Update user data
  static Future<void> updateUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user));
  }

  // Biometric Authentication Methods
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> authenticateWithBiometrics() async {
    try {
      print('=== AUTHENTICATE WITH BIOMETRICS STARTED ===');
      
      // Coba langsung autentikasi tanpa pengecekan
      final result = await _localAuth.authenticate(
        localizedReason: 'Silakan scan sidik jari di tombol power untuk login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      
      print('Biometric authentication result: $result');
      return result;
    } catch (e) {
      print('Error during biometric authentication: $e');
      print('Error details: ${e.toString()}');
      return false;
    }
  }

  // Enable/Disable biometric login
  static Future<void> enableBiometricLogin(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, true);
    await prefs.setString(_biometricCredentialsKey, json.encode({
      'email': email,
      'password': password,
    }));
  }

  static Future<void> disableBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, false);
    await prefs.remove(_biometricCredentialsKey);
  }

  static Future<bool> isBiometricLoginEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  static Future<Map<String, dynamic>?> getBiometricCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final credentialsString = prefs.getString(_biometricCredentialsKey);
    if (credentialsString != null) {
      return json.decode(credentialsString);
    }
    return null;
  }
} 