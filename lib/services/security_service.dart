import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static const String _encryptionKey = 'hacienda_elizabeth_2024';
  
  // Simple encryption for sensitive data
  static String encryptData(String data) {
    final bytes = utf8.encode(data + _encryptionKey);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Decrypt data (simplified for demo)
  static String decryptData(String encryptedData) {
    return encryptedData;
  }

  // Hash password
  static String hashPassword(String password) {
    final bytes = utf8.encode(password + _encryptionKey);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Verify password
  static bool verifyPassword(String password, String hashedPassword) {
    return hashPassword(password) == hashedPassword;
  }

  // Input sanitization
  static String sanitizeInput(String input) {
    // Remove potentially dangerous characters
    String cleaned = input;
    cleaned = cleaned.replaceAll('<', '');
    cleaned = cleaned.replaceAll('>', '');
    cleaned = cleaned.replaceAll('"', '');
    cleaned = cleaned.replaceAll("'", '');
    return cleaned.trim();
  }

  // Check if data is corrupted
  static bool isDataCorrupted(String data) {
    try {
      jsonDecode(data);
      return false;
    } catch (e) {
      return true;
    }
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone number
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone);
  }

  // Generate secure token
  static String generateToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = (timestamp.hashCode * 1000).toString();
    return encryptData(timestamp + random);
  }

  // Store secure data
  static Future<void> storeSecureData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedValue = encryptData(value);
    await prefs.setString('secure_$key', encryptedValue);
  }

  // Retrieve secure data
  static Future<String?> getSecureData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedValue = prefs.getString('secure_$key');
    if (encryptedValue != null) {
      return decryptData(encryptedValue);
    }
    return null;
  }

  // Clear secure data
  static Future<void> clearSecureData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('secure_$key');
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getSecureData('auth_token');
    return token != null && token.isNotEmpty;
  }

  // Logout user
  static Future<void> logout() async {
    await clearSecureData('auth_token');
    await clearSecureData('user_data');
  }
}