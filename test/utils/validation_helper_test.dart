import 'package:flutter_test/flutter_test.dart';

import 'package:sample/utils/validation_helper.dart';

void main() {
  group('ValidationHelper.validateEmail', () {
    test('returns error when email is null or empty', () {
      expect(ValidationHelper.validateEmail(null), 'Email is required');
      expect(ValidationHelper.validateEmail(''), 'Email is required');
    });

    test('returns error for malformed email', () {
      expect(
        ValidationHelper.validateEmail('invalid-email'),
        'Please enter a valid email',
      );
    });

    test('returns null for valid email', () {
      expect(ValidationHelper.validateEmail('user@example.com'), isNull);
    });
  });

  group('ValidationHelper.validatePhone', () {
    test('returns error when phone is missing', () {
      expect(ValidationHelper.validatePhone(null), 'Phone number is required');
      expect(ValidationHelper.validatePhone(''), 'Phone number is required');
    });

    test('returns error for invalid number formats', () {
      expect(
        ValidationHelper.validatePhone('abc'),
        'Please enter a valid phone number',
      );
    });

    test('accepts international E.164 numbers', () {
      expect(ValidationHelper.validatePhone('+639171234567'), isNull);
    });
  });

  group('ValidationHelper.validateNumber', () {
    test('rejects non-numeric values', () {
      expect(
        ValidationHelper.validateNumber('abc', 'Quantity'),
        'Quantity must be a valid number',
      );
    });

    test('enforces minimum and maximum bounds', () {
      expect(
        ValidationHelper.validateNumber('-1', 'Quantity', min: 0, max: 10),
        'Quantity must be at least 0',
      );
      expect(
        ValidationHelper.validateNumber('20', 'Quantity', min: 0, max: 10),
        'Quantity must be at most 10',
      );
    });

    test('returns null when within range', () {
      expect(
        ValidationHelper.validateNumber('5', 'Quantity', min: 0, max: 10),
        isNull,
      );
    });
  });

  test('validateSugarHeight proxies to validateNumber with bounds', () {
    expect(
      ValidationHelper.validateSugarHeight('-1'),
      'Height must be at least 0',
    );
    expect(ValidationHelper.validateSugarHeight('250'), isNull);
    expect(
      ValidationHelper.validateSugarHeight('600'),
      'Height must be at most 500',
    );
  });
}


