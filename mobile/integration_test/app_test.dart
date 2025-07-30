import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:indowater_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify splash screen and onboarding flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify splash screen is displayed
      expect(find.byType(Image), findsWidgets);
      
      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Verify onboarding screen is displayed
      expect(find.text('Get Started'), findsOneWidget);
      
      // Swipe through onboarding screens
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      
      // Tap the get started button
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      
      // Verify login screen is displayed
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('verify login flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      
      // Skip splash and onboarding
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // If on onboarding screen, skip it
      if (find.text('Get Started').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
      }
      
      // Verify login screen is displayed
      expect(find.text('Login'), findsOneWidget);
      
      // Enter invalid credentials
      await tester.enterText(find.byType(TextFormField).at(0), 'invalid@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpassword');
      
      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // Verify error message is displayed
      expect(find.textContaining('Invalid'), findsOneWidget);
      
      // Clear fields and enter valid credentials
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      
      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // Verify dashboard is displayed
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('verify dashboard navigation', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      
      // Skip to dashboard (assuming we're logged in)
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // If on onboarding screen, skip it
      if (find.text('Get Started').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
      }
      
      // If on login screen, login
      if (find.text('Login').evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle();
      }
      
      // Verify dashboard is displayed
      expect(find.text('Dashboard'), findsOneWidget);
      
      // Navigate to meters screen
      await tester.tap(find.text('Meters'));
      await tester.pumpAndSettle();
      
      // Verify meters screen is displayed
      expect(find.text('My Meters'), findsOneWidget);
      
      // Navigate to consumption screen
      await tester.tap(find.text('Consumption'));
      await tester.pumpAndSettle();
      
      // Verify consumption screen is displayed
      expect(find.text('Water Consumption'), findsOneWidget);
      
      // Navigate to payments screen
      await tester.tap(find.text('Payments'));
      await tester.pumpAndSettle();
      
      // Verify payments screen is displayed
      expect(find.text('Payments'), findsOneWidget);
      
      // Navigate to profile screen
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      
      // Verify profile screen is displayed
      expect(find.text('Profile'), findsOneWidget);
      
      // Navigate back to dashboard
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      
      // Verify dashboard is displayed
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}