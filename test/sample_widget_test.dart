import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class GreetingWidget extends StatelessWidget {
  final String name;
  const GreetingWidget({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Hacienda Elizabeth')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hello, $name'),
              ElevatedButton(
                onPressed: () {},
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('GreetingWidget renders expected UI elements', (tester) async {
    await tester.pumpWidget(const GreetingWidget(name: 'Dex'));

    expect(find.text('Hacienda Elizabeth'), findsOneWidget);
    expect(find.text('Hello, Dex'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'OK'), findsOneWidget);
  });

  testWidgets('Button is tappable', (tester) async {
    await tester.pumpWidget(const GreetingWidget(name: 'QA'));
    final okButton = find.widgetWithText(ElevatedButton, 'OK');
    expect(okButton, findsOneWidget);
    await tester.tap(okButton);
    await tester.pump();
  });
}


