import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indowater_mobile/main.dart' as app;
import 'package:indowater_mobile/providers/auth_provider.dart';
import 'package:indowater_mobile/services/api_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockApiService extends Mock implements ApiService {}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockApiService mockApiService;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockApiService = MockApiService();
  });

  testWidgets('Login flow - successful login', (WidgetTester tester) async {
    // Mock successful login
    when(mockAuthProvider.login(
      email: 'test@example.com',
      password: 'password123',
    )).thenAnswer((_) async => true);

    // Build our app wrapped with the mocked providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          Provider<ApiService>.value(value: mockApiService),
        ],
        child: const app.MyApp(),
      ),
    );

    // Wait for splash screen
    await tester.pump(const Duration(seconds: 2));
    
    // Navigate to login screen (this depends on your app's navigation)
    // For this test, we assume the app navigates to login after splash
    await tester.pumpAndSettle();
    
    // Verify we're on the login screen
    expect(find.text('Sign in to continue to IndoWater'), findsOneWidget);
    
    // Enter email and password
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    
    // Tap the login button
    await tester.tap(find.text('Login'));
    await tester.pump();
    
    // Verify login method was called
    verify(mockAuthProvider.login(
      email: 'test@example.com',
      password: 'password123',
    )).called(1);
  });

  testWidgets('Login flow - validation errors', (WidgetTester tester) async {
    // Build our app wrapped with the mocked providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          Provider<ApiService>.value(value: mockApiService),
        ],
        child: const app.MyApp(),
      ),
    );

    // Wait for splash screen
    await tester.pump(const Duration(seconds: 2));
    
    // Navigate to login screen
    await tester.pumpAndSettle();
    
    // Verify we're on the login screen
    expect(find.text('Sign in to continue to IndoWater'), findsOneWidget);
    
    // Tap the login button without entering any data
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    
    // Verify validation error messages are shown
    expect(find.text('This field is required'), findsWidgets);
    
    // Enter invalid email
    await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
    await tester.pump();
    
    // Tap the login button
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    
    // Verify email validation error is shown
    expect(find.text('Please enter a valid email address'), findsOneWidget);
  });

  testWidgets('Login flow - failed login', (WidgetTester tester) async {
    // Mock failed login
    when(mockAuthProvider.login(
      email: 'test@example.com',
      password: 'wrong-password',
    )).thenThrow(Exception('Invalid credentials'));

    // Build our app wrapped with the mocked providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          Provider<ApiService>.value(value: mockApiService),
        ],
        child: const app.MyApp(),
      ),
    );

    // Wait for splash screen
    await tester.pump(const Duration(seconds: 2));
    
    // Navigate to login screen
    await tester.pumpAndSettle();
    
    // Verify we're on the login screen
    expect(find.text('Sign in to continue to IndoWater'), findsOneWidget);
    
    // Enter email and wrong password
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong-password');
    
    // Tap the login button
    await tester.tap(find.text('Login'));
    await tester.pump();
    
    // Verify login method was called
    verify(mockAuthProvider.login(
      email: 'test@example.com',
      password: 'wrong-password',
    )).called(1);
    
    // Pump to show error message
    await tester.pumpAndSettle();
    
    // Verify error message is shown (this depends on how your app shows errors)
    expect(find.text('Invalid credentials'), findsOneWidget);
  });

  testWidgets('Login flow - navigate to forgot password', (WidgetTester tester) async {
    // Build our app wrapped with the mocked providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          Provider<ApiService>.value(value: mockApiService),
        ],
        child: const app.MyApp(),
      ),
    );

    // Wait for splash screen
    await tester.pump(const Duration(seconds: 2));
    
    // Navigate to login screen
    await tester.pumpAndSettle();
    
    // Verify we're on the login screen
    expect(find.text('Sign in to continue to IndoWater'), findsOneWidget);
    
    // Tap the forgot password link
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();
    
    // Verify we're on the forgot password screen
    expect(find.text('Reset Password'), findsOneWidget);
  });

  testWidgets('Login flow - navigate to register', (WidgetTester tester) async {
    // Build our app wrapped with the mocked providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          Provider<ApiService>.value(value: mockApiService),
        ],
        child: const app.MyApp(),
      ),
    );

    // Wait for splash screen
    await tester.pump(const Duration(seconds: 2));
    
    // Navigate to login screen
    await tester.pumpAndSettle();
    
    // Verify we're on the login screen
    expect(find.text('Sign in to continue to IndoWater'), findsOneWidget);
    
    // Tap the register link
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    
    // Verify we're on the register screen
    expect(find.text('Create Account'), findsOneWidget);
  });
}