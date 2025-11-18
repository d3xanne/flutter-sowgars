import 'package:flutter_test/flutter_test.dart';
import 'package:sample/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('should have supabase URL', () {
      expect(AppConfig.supabaseUrl, isNotEmpty);
      expect(AppConfig.supabaseUrl, startsWith('https://'));
    });

    test('should have supabase anon key', () {
      expect(AppConfig.supabaseAnonKey, isNotEmpty);
    });

    test('should have encryption key', () {
      expect(AppConfig.encryptionKey, isNotEmpty);
    });
  });
}

