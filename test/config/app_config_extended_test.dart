import 'package:flutter_test/flutter_test.dart';
import 'package:sample/config/app_config.dart';

void main() {
  group('AppConfig Extended Tests', () {
    test('should access supabase URL', () {
      final url = AppConfig.supabaseUrl;
      expect(url, isNotEmpty);
      expect(url, startsWith('https://'));
    });

    test('should access supabase anon key', () {
      final key = AppConfig.supabaseAnonKey;
      expect(key, isNotEmpty);
      expect(key.length, greaterThan(50));
    });

    test('should access encryption key', () {
      final key = AppConfig.encryptionKey;
      expect(key, isNotEmpty);
    });

    test('should have valid URL format', () {
      final url = AppConfig.supabaseUrl;
      expect(Uri.tryParse(url), isNotNull);
    });
  });
}

