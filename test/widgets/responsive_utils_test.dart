import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sample/widgets/responsive_builder.dart';

void main() {
  Future<T> _withScreen<T>(
    WidgetTester tester,
    Size size,
    T Function(BuildContext context) callback,
  ) async {
    late T result;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: Builder(
            builder: (context) {
              result = callback(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    return result;
  }

  group('ResponsiveUtils device type helpers', () {
    testWidgets('detects mobile, tablet, and desktop breakpoints',
        (tester) async {
      expect(
        await _withScreen(tester, const Size(320, 640), ResponsiveUtils.isMobile),
        isTrue,
      );
      expect(
        await _withScreen(tester, const Size(800, 1024), ResponsiveUtils.isTablet),
        isTrue,
      );
      expect(
        await _withScreen(tester, const Size(1400, 900), ResponsiveUtils.isDesktop),
        isTrue,
      );
    });
  });

  group('ResponsiveUtils padding helpers', () {
    testWidgets('returns smaller padding for mobile', (tester) async {
      final padding = await _withScreen(
        tester,
        const Size(375, 812),
        ResponsiveUtils.getPadding,
      );
      expect(padding, const EdgeInsets.all(12));
    });

    testWidgets('returns larger padding for desktop', (tester) async {
      final padding = await _withScreen(
        tester,
        const Size(1600, 900),
        ResponsiveUtils.getPadding,
      );
      expect(padding, const EdgeInsets.all(24));
    });
  });

  group('ResponsiveBuilder widget selection', () {
    testWidgets('switches child widget by width constraints', (tester) async {
      const mobileKey = Key('mobile-view');
      const desktopKey = Key('desktop-view');

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Future<void> pumpWithWidth(double width) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = Size(width, 800);

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveBuilder(
              mobile: const Placeholder(key: mobileKey),
              desktop: const Placeholder(key: desktopKey),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pumpWithWidth(400);
      expect(find.byKey(mobileKey), findsOneWidget);
      expect(find.byKey(desktopKey), findsNothing);

      await pumpWithWidth(1400);
      expect(find.byKey(desktopKey), findsOneWidget);
      expect(find.byKey(mobileKey), findsNothing);
    });
  });
}


