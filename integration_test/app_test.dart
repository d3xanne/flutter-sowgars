import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

// Attempt to import the app's main entry. Adjust if your main file differs.
import 'package:sample/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App boots to first frame', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Minimal sanity checks: app renders something and has a root Material widget
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
  });
}


