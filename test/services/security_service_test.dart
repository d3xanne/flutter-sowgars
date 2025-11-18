import 'package:flutter_test/flutter_test.dart';
import 'package:sample/services/security_service.dart';

void main() {
  group('SecurityService', () {
    test('should hash password correctly', () {
      final password = 'testPassword123';
      final hashed = SecurityService.hashPassword(password);
      
      expect(hashed, isNotEmpty);
      expect(hashed.length, greaterThan(0));
      expect(hashed, isNot(equals(password)));
    });

    test('should verify password correctly', () {
      final password = 'testPassword123';
      final hashed = SecurityService.hashPassword(password);
      
      expect(SecurityService.verifyPassword(password, hashed), isTrue);
      expect(SecurityService.verifyPassword('wrongPassword', hashed), isFalse);
    });

    test('should sanitize input correctly', () {
      final input = '<script>alert("xss")</script>';
      final sanitized = SecurityService.sanitizeInput(input);
      
      expect(sanitized, isNot(contains('<')));
      expect(sanitized, isNot(contains('>')));
      expect(sanitized, isNot(contains('"')));
      expect(sanitized, isNot(contains("'")));
    });

    test('should validate email format', () {
      expect(SecurityService.isValidEmail('test@example.com'), isTrue);
      expect(SecurityService.isValidEmail('invalid.email'), isFalse);
      expect(SecurityService.isValidEmail('test@'), isFalse);
    });

    test('should validate phone number format', () {
      expect(SecurityService.isValidPhone('+1234567890'), isTrue);
      expect(SecurityService.isValidPhone('1234567890'), isTrue);
      expect(SecurityService.isValidPhone('invalid'), isFalse);
    });

    test('should check if data is corrupted', () {
      expect(SecurityService.isDataCorrupted('{"valid": "json"}'), isFalse);
      expect(SecurityService.isDataCorrupted('invalid json'), isTrue);
    });

    test('should generate token', () {
      final token1 = SecurityService.generateToken();
      
      expect(token1, isNotEmpty);
      expect(token1.length, greaterThan(0));
      expect(token1, isA<String>());
    });

    test('should encrypt data', () {
      final data = 'sensitive data';
      final encrypted = SecurityService.encryptData(data);
      
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(equals(data)));
    });
  });
}

