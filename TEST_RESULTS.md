# System Code Health Report
_Generated: November 17, 2025_

## Commands Executed
- `flutter analyze`
- `flutter test --coverage`

## flutter analyze
- Result: **Passed** (0 issues)
- Key fixes applied:
  - Removed unused imports/members and retired dead helper methods across `lib/` screens, widgets, and services.
  - Replaced deprecated APIs (radio selections, dropdown `initialValue`, theme background colors, widget tester `window` access, etc.).
  - Refactored safe-state utilities to avoid protected `setState` misuse and modernised system health/validator stream checks.
  - Migrated web download helper from `dart:html` to `package:web` (data-URI anchor) and cleaned up unsupported APIs.

## flutter test --coverage
- Result: **Passed** (19 tests)
- Suites:
  - `test/sample_unit_test.dart`
  - `test/sample_widget_test.dart`
  - `test/utils/validation_helper_test.dart`
  - `test/widgets/responsive_utils_test.dart`
- Coverage artifact: `coverage/lcov.info` (use `genhtml coverage/lcov.info -o coverage/html` for HTML output).

## Outstanding Items
- Integration tests remain blocked until an Android/iOS device is connected; run `flutter test integration_test -d <deviceId>` once available.
- Consider regenerating coverage HTML (`genhtml coverage/lcov.info -o coverage/html`) for reporting if needed.


