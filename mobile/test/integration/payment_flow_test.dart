import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indowater_mobile/main.dart' as app;
import 'package:indowater_mobile/providers/auth_provider.dart';
import 'package:indowater_mobile/services/api_service.dart';
import 'package:indowater_mobile/services/meter_service.dart';
import 'package:indowater_mobile/services/payment_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockApiService extends Mock implements ApiService {}
class MockMeterService extends Mock implements MeterService {}
class MockPaymentService extends Mock implements PaymentService {}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockApiService mockApiService;
  late MockMeterService mockMeterService;
  late MockPaymentService mockPaymentService;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockApiService = MockApiService();
    mockMeterService = MockMeterService();
    mockPaymentService = MockPaymentService();
    
    // Mock authentication state
    when(mockAuthProvider.isAuthenticated).thenReturn(true);
    when(mockAuthProvider.currentUser).thenReturn(null);
  });

  testWidgets('Payment flow - view payment history', (WidgetTester tester) async {
    // Mock payment history
    final mockPayments = [
      {
        'id': '1',
        'title': 'Top-up',
        'description': 'Top-up transaction',
        'amount': 100.0,
        'status': 'success',
        'payment_method': 'Credit Card',
        'meter_number': 'M12345',
        'type': 'topup',
        'date': '2023-01-01T00:00:00.000Z',
      },
      {
        'id': '2',
        'title': 'Bill Payment',
        'description': 'Bill payment transaction',
        'amount': 50.0,
        'status': 'success',
        'payment_method': 'Bank Transfer',
        'meter_number': 'M12345',
        'type': 'bill',
        'date': '2023-01-02T00:00:00.000Z',
      },
    ];
    
    when(mockPaymentService.getPaymentHistory()).thenAnswer((_) async => mockPayments);
    when(mockMeterService.getUserMeters()).thenAnswer((_) async => []);

    // Build our app wrapped with the mocked providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          Provider<ApiService>.value(value: mockApiService),
          Provider<MeterService>.value(value: mockMeterService),
          Provider<PaymentService>.value(value: mockPaymentService),
        ],
        child: const app.MyApp(),
      ),
    );

    // Wait for splash screen and navigate to dashboard
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    
    // Navigate to payments screen
    await tester.tap(find.text('Payments'));
    await tester.pumpAndSettle();
    
    // Verify we're on the payments screen
    expect(find.text('Payments'), findsOneWidget);
    
    // Verify the payments are displayed
    expect(find.text('Top-up'), findsOneWidget);
    expect(find.text('Bill Payment'), findsOneWidget);
    
    // Verify the tabs are displayed
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Top-ups'), findsOneWidget);
    expect(find.text('Bills'), findsOneWidget);
    
    // Tap on the Top-ups tab
    await tester.tap(find.text('Top-ups'));
    await tester.pumpAndSettle();
    
    // Verify only top-up payments are displayed
    expect(find.text('Top-up'), findsOneWidget);
    expect(find.text('Bill Payment'), findsNothing);
    
    // Tap on the Bills tab
    await tester.tap(find.text('Bills'));
    await tester.pumpAndSettle();
    
    // Verify only bill payments are displayed
    expect(find.text('Top-up'), findsNothing);
    expect(find.text('Bill Payment'), findsOneWidget);
  });

  testWidgets('Payment flow - view payment details', (WidgetTester tester) async {
    // Mock payment history
    final mockPayments = [
      {
        'id': '1',
        'title': 'Top-up',
        'description': 'Top-up transaction',
        'amount': 100.0,
        'status': 'success',
        'payment_method': 'Credit Card',
        'meter_number': 'M12345',
        'type': 'topup',
        'date': '2023-01-01T00:00:00.000Z',
      },
    ];
    
    // Mock payment details
    final mockPaymentDetails = {
      'id': '1',
      'title': 'Top-up',
      'description': 'Top-up transaction',
      'amount': 100.0,
      'status': 'success',
      'payment_method': 'Credit Card',
      'meter_number': 'M12345',
      'type': 'topup',
      'date': '2023-01-01T00:00:00.000Z',
      'transaction_id': 'TRX123456',
      'reference_id': 'REF123456',
    };
    
    when(mockPaymentService.getPaymentHistory()).thenAnswer((_) async => mockPayments);
    when(mockPaymentService.getPaymentDetails('1')).thenAnswer((_) async => mockPaymentDetails);
    when(mockMeterService.getUserMeters()).thenAnswer((_) async => []);

    // Build our app wrapped with the mocked providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          Provider<ApiService>.value(value: mockApiService),
          Provider<MeterService>.value(value: mockMeterService),
          Provider<PaymentService>.value(value: mockPaymentService),
        ],
        child: const app.MyApp(),
      ),
    );

    // Wait for splash screen and navigate to dashboard
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    
    // Navigate to payments screen
    await tester.tap(find.text('Payments'));
    await tester.pumpAndSettle();
    
    // Tap on the first payment to view details
    await tester.tap(find.text('View Details').first);
    await tester.pumpAndSettle();
    
    // Verify we're on the payment details screen
    expect(find.text('Payment Details'), findsOneWidget);
    
    // Verify the payment details are displayed
    expect(find.text('Top-up'), findsOneWidget);
    expect(find.text('Credit Card'), findsOneWidget);
    expect(find.text('TRX123456'), findsOneWidget);
    expect(find.text('REF123456'), findsOneWidget);
    
    // Verify the status is displayed
    expect(find.text('SUCCESS'), findsOneWidget);
    
    // Verify the download receipt button is displayed
    expect(find.text('Download Receipt'), findsOneWidget);
  });

  testWidgets('Payment flow - top up process', (WidgetTester tester) async {
    // Mock meter list
    final mockMeters = [
      {
        'id': '1',
        'meter_number': 'M12345',
        'nickname': 'Home Meter',
        'address': '123 Main St',
        'status': 'active',
        'balance': 100.0,
        'last_reading': 50.0,
        'last_reading_date': '2023-01-01T00:00:00.000Z',
      },
    ];
    
    // Mock successful payment
    final mockPaymentResult = {
      'status': PaymentStatus.success,
      'transaction_id': 'TRX123456',
    };
    
    when(mockMeterService.getUserMeters()).thenAnswer((_) async => mockMeters);
    when(mockPaymentService.initializeMidtrans()).thenAnswer((_) async => true);
    when(mockPaymentService.processTopup(
      amount: 100.0,
      paymentMethod: 'credit_card',
    )).thenAnswer((_) async => mockPaymentResult);

    // Build our app wrapped with the mocked providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          Provider<ApiService>.value(value: mockApiService),
          Provider<MeterService>.value(value: mockMeterService),
          Provider<PaymentService>.value(value: mockPaymentService),
        ],
        child: const app.MyApp(),
      ),
    );

    // Wait for splash screen and navigate to dashboard
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    
    // Navigate to top up screen
    await tester.tap(find.text('Top Up'));
    await tester.pumpAndSettle();
    
    // Verify we're on the top up screen
    expect(find.text('Top Up'), findsOneWidget);
    
    // Verify the meter is displayed
    expect(find.text('Home Meter'), findsOneWidget);
    
    // Select an amount (100,000)
    await tester.tap(find.text('Rp 100.000'));
    await tester.pumpAndSettle();
    
    // Select payment method
    await tester.tap(find.text('Credit/Debit Card'));
    await tester.pumpAndSettle();
    
    // Verify the payment summary is displayed
    expect(find.text('Payment Summary'), findsOneWidget);
    
    // Tap the pay now button
    await tester.tap(find.text('Pay Now'));
    await tester.pumpAndSettle();
    
    // Verify the payment service was called
    verify(mockPaymentService.processTopup(
      amount: 100.0,
      paymentMethod: 'credit_card',
    )).called(1);
    
    // Verify we're on the success screen
    expect(find.text('Top-up Successful!'), findsOneWidget);
  });

  testWidgets('Payment flow - pending payment', (WidgetTester tester) async {
    // Mock meter list
    final mockMeters = [
      {
        'id': '1',
        'meter_number': 'M12345',
        'nickname': 'Home Meter',
        'address': '123 Main St',
        'status': 'active',
        'balance': 100.0,
        'last_reading': 50.0,
        'last_reading_date': '2023-01-01T00:00:00.000Z',
      },
    ];
    
    // Mock pending payment
    final mockPaymentResult = {
      'status': PaymentStatus.pending,
      'transaction_id': 'TRX123456',
    };
    
    when(mockMeterService.getUserMeters()).thenAnswer((_) async => mockMeters);
    when(mockPaymentService.initializeMidtrans()).thenAnswer((_) async => true);
    when(mockPaymentService.processTopup(
      amount: 100.0,
      paymentMethod: 'bank_transfer',
    )).thenAnswer((_) async => mockPaymentResult);

    // Build our app wrapped with the mocked providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          Provider<ApiService>.value(value: mockApiService),
          Provider<MeterService>.value(value: mockMeterService),
          Provider<PaymentService>.value(value: mockPaymentService),
        ],
        child: const app.MyApp(),
      ),
    );

    // Wait for splash screen and navigate to dashboard
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    
    // Navigate to top up screen
    await tester.tap(find.text('Top Up'));
    await tester.pumpAndSettle();
    
    // Select an amount (100,000)
    await tester.tap(find.text('Rp 100.000'));
    await tester.pumpAndSettle();
    
    // Select payment method
    await tester.tap(find.text('Bank Transfer'));
    await tester.pumpAndSettle();
    
    // Tap the pay now button
    await tester.tap(find.text('Pay Now'));
    await tester.pumpAndSettle();
    
    // Verify the payment service was called
    verify(mockPaymentService.processTopup(
      amount: 100.0,
      paymentMethod: 'bank_transfer',
    )).called(1);
    
    // Verify we're on the confirmation screen
    expect(find.text('Payment Processing'), findsOneWidget);
    expect(find.text('Time Remaining'), findsOneWidget);
    
    // Verify the check status button is displayed
    expect(find.text('Check Status'), findsOneWidget);
  });

  testWidgets('Payment flow - failed payment', (WidgetTester tester) async {
    // Mock meter list
    final mockMeters = [
      {
        'id': '1',
        'meter_number': 'M12345',
        'nickname': 'Home Meter',
        'address': '123 Main St',
        'status': 'active',
        'balance': 100.0,
        'last_reading': 50.0,
        'last_reading_date': '2023-01-01T00:00:00.000Z',
      },
    ];
    
    // Mock failed payment
    final mockPaymentResult = {
      'status': PaymentStatus.failed,
      'error': 'Payment failed',
    };
    
    when(mockMeterService.getUserMeters()).thenAnswer((_) async => mockMeters);
    when(mockPaymentService.initializeMidtrans()).thenAnswer((_) async => true);
    when(mockPaymentService.processTopup(
      amount: 100.0,
      paymentMethod: 'e_wallet',
    )).thenAnswer((_) async => mockPaymentResult);

    // Build our app wrapped with the mocked providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          Provider<ApiService>.value(value: mockApiService),
          Provider<MeterService>.value(value: mockMeterService),
          Provider<PaymentService>.value(value: mockPaymentService),
        ],
        child: const app.MyApp(),
      ),
    );

    // Wait for splash screen and navigate to dashboard
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    
    // Navigate to top up screen
    await tester.tap(find.text('Top Up'));
    await tester.pumpAndSettle();
    
    // Select an amount (100,000)
    await tester.tap(find.text('Rp 100.000'));
    await tester.pumpAndSettle();
    
    // Select payment method
    await tester.tap(find.text('E-Wallet'));
    await tester.pumpAndSettle();
    
    // Tap the pay now button
    await tester.tap(find.text('Pay Now'));
    await tester.pumpAndSettle();
    
    // Verify the payment service was called
    verify(mockPaymentService.processTopup(
      amount: 100.0,
      paymentMethod: 'e_wallet',
    )).called(1);
    
    // Verify we're on the failed screen
    expect(find.text('Top-up Failed'), findsOneWidget);
    expect(find.text('Payment failed'), findsOneWidget);
    
    // Verify the try again button is displayed
    expect(find.text('Try Again'), findsOneWidget);
  });
}