import 'package:test/test.dart';

int addNumbers(int a, int b) => a + b;

bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^.+@.+\..+$');
  return emailRegex.hasMatch(email);
}

String normalizeWhitespace(String input) => input.replaceAll(RegExp(r'\s+'), ' ').trim();

void main() {
  group('Pure Dart unit tests', () {
    test('addNumbers returns correct sum', () {
      expect(addNumbers(2, 3), 5);
      expect(addNumbers(-1, 1), 0);
    });

    test('isValidEmail validates basic email format', () {
      expect(isValidEmail('user@example.com'), isTrue);
      expect(isValidEmail('invalid@domain'), isFalse);
      expect(isValidEmail('nodomain@'), isFalse);
      expect(isValidEmail('plain-address'), isFalse);
    });

    test('normalizeWhitespace collapses and trims whitespace', () {
      expect(normalizeWhitespace('  hello   world  '), 'hello world');
      expect(normalizeWhitespace('\nline1\n\nline2\t  line3'), 'line1 line2 line3');
    });
  });
}


