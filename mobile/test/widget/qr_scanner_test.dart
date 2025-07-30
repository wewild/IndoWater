import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indowater_mobile/components/qr_scanner.dart';

void main() {
  testWidgets('QRScanner renders correctly', (WidgetTester tester) async {
    // Build the QRScanner widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QRScanner(
            onScanSuccess: (String data) {},
            onClose: () {},
          ),
        ),
      ),
    );

    // Verify that the scanner is rendered
    expect(find.byType(QRScanner), findsOneWidget);
    
    // Verify that the close button is displayed
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('QRScanner calls onClose when close button is tapped', (WidgetTester tester) async {
    bool closeWasTapped = false;
    
    // Build the QRScanner widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QRScanner(
            onScanSuccess: (String data) {},
            onClose: () {
              closeWasTapped = true;
            },
          ),
        ),
      ),
    );

    // Verify that the scanner is rendered
    expect(find.byType(QRScanner), findsOneWidget);
    
    // Tap the close button
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    
    // Verify that the callback was called
    expect(closeWasTapped, isTrue);
  });

  testWidgets('QRScanner displays overlay with scan area', (WidgetTester tester) async {
    // Build the QRScanner widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QRScanner(
            onScanSuccess: (String data) {},
            onClose: () {},
          ),
        ),
      ),
    );

    // Verify that the scanner is rendered
    expect(find.byType(QRScanner), findsOneWidget);
    
    // Verify that the overlay is displayed
    expect(find.byType(CustomPaint), findsOneWidget);
  });

  testWidgets('QRScanner displays scanning instructions', (WidgetTester tester) async {
    // Build the QRScanner widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QRScanner(
            onScanSuccess: (String data) {},
            onClose: () {},
          ),
        ),
      ),
    );

    // Verify that the scanner is rendered
    expect(find.byType(QRScanner), findsOneWidget);
    
    // Verify that the instructions are displayed
    expect(find.text('Scan QR Code'), findsOneWidget);
    expect(find.text('Position the QR code within the frame to scan'), findsOneWidget);
  });

  testWidgets('QRScanner displays torch button', (WidgetTester tester) async {
    // Build the QRScanner widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QRScanner(
            onScanSuccess: (String data) {},
            onClose: () {},
          ),
        ),
      ),
    );

    // Verify that the scanner is rendered
    expect(find.byType(QRScanner), findsOneWidget);
    
    // Verify that the torch button is displayed
    expect(find.byIcon(Icons.flash_off), findsOneWidget);
  });
}