import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mrz_scanner/src/ui/mrz_scanner_overlay.dart';

void main() {
  group('MrzScannerOverlay Widget Tests', () {
    testWidgets('renders without throwing exceptions with default properties', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MrzScannerOverlay())),
      );

      expect(find.byType(MrzScannerOverlay), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byType(IgnorePointer), findsWidgets);
    });

    testWidgets('renders correctly with custom properties', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MrzScannerOverlay(
              overlayColor: Colors.blue,
              borderColor: Colors.yellow,
              borderStrokeWidth: 5.0,
              cornerLength: 40.0,
              aspectRatio: 1.0,
              widthRatio: 0.8,
            ),
          ),
        ),
      );

      expect(find.byType(MrzScannerOverlay), findsOneWidget);
    });
  });
}
