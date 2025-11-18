import 'package:flutter_test/flutter_test.dart';
import 'package:sample/services/supabase_service.dart';

void main() {
  group('SupabaseService', () {
    test('should have isReady getter', () {
      expect(SupabaseService.isReady, isA<bool>());
    });

    test('should throw exception when client accessed before initialization', () {
      // Note: This test assumes SupabaseService is not initialized
      // In a real scenario, you might need to reset the service state
      expect(() => SupabaseService.client, throwsException);
    });
  });
}

