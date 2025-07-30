import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indowater_mobile/main.dart' as app;
import 'package:indowater_mobile/providers/auth_provider.dart';
import 'package:indowater_mobile/services/api_service.dart';
import 'package:indowater_mobile/services/meter_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockApiService extends Mock implements ApiService {}
class MockMeterService extends Mock implements MeterService {}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockApiService mockApiService;
  late MockMeterService mockMeterService;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockApiService = MockApiService();
    mockMeterService = MockMeterService();
    
    // Mock authentication state
    when(mockAuthProvider.isAuthenticated).thenReturn(true);
    when(mockAuthProvider.currentUser).thenReturn(null);
  });

  testWidgets('Meter management - view meters list', (WidgetTester tester) async {
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
      {
        'id': '2',
        'meter_number': 'M67890',
        'nickname': 'Office Meter',
        'address': '456 Business Ave',
        'status': 'active',
        'balance': 200.0,
        'last_reading': 75.0,
        'last_reading_date': '2023-01-01T00:00:00.000Z',
      },
    ];
    
    when(mockMeterService.getUserMeters()).thenAnswer((_) async => mockMeters);

    // Build our app wrapped with the mocked providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          Provider<ApiService>.value(value: mockApiService),
          Provider<MeterService>.value(value: mockMeterService),
        ],
        child: const app.MyApp(),
      ),
    );

    // Wait for splash screen and navigate to dashboard
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    
    // Navigate to meters screen
    await tester.tap(find.text('My Meters'));
    await tester.pumpAndSettle();
    
    // Verify we're on the meters screen
    expect(find.text('My Meters'), findsOneWidget);
    
    // Verify the meters are displayed
    expect(find.text('Home Meter'), findsOneWidget);
    expect(find.text('Office Meter'), findsOneWidget);
    expect(find.text('M12345'), findsOneWidget);
    expect(find.text('M67890'), findsOneWidget);
  });

  testWidgets('Meter management - view meter details', (WidgetTester tester) async {
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
    
    // Mock meter details
    final mockMeterDetails = {
      'id': '1',
      'meter_number': 'M12345',
      'nickname': 'Home Meter',
      'address': '123 Main St',
      'status': 'active',
      'balance': 100.0,
      'last_reading': 50.0,
      'last_reading_date': '2023-01-01T00:00:00.000Z',
    };
    
    // Mock consumption history
    final mockConsumptionHistory = [
      {
        'id': '1',
        'meter_id': '1',
        'reading': 50.0,
        'value': 10.0,
        'date': '2023-01-01T00:00:00.000Z',
      },
    ];
    
    // Mock payment history
    final mockPaymentHistory = [
      {
        'id': '1',
        'meter_id': '1',
        'amount': 50.0,
        'status': 'success',
        'date': '2023-01-01T00:00:00.000Z',
      },
    ];
    
    when(mockMeterService.getUserMeters()).thenAnswer((_) async => mockMeters);
    when(mockMeterService.getMeterDetails('1')).thenAnswer((_) async => mockMeterDetails);
    when(mockMeterService.getMeterConsumptionHistory('1')).thenAnswer((_) async => mockConsumptionHistory);
    when(mockMeterService.getMeterPaymentHistory('1')).thenAnswer((_) async => mockPaymentHistory);

    // Build our app wrapped with the mocked providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          Provider<ApiService>.value(value: mockApiService),
          Provider<MeterService>.value(value: mockMeterService),
        ],
        child: const app.MyApp(),
      ),
    );

    // Wait for splash screen and navigate to dashboard
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    
    // Navigate to meters screen
    await tester.tap(find.text('My Meters'));
    await tester.pumpAndSettle();
    
    // Tap on the first meter to view details
    await tester.tap(find.text('View Details').first);
    await tester.pumpAndSettle();
    
    // Verify we're on the meter details screen
    expect(find.text('Home Meter'), findsOneWidget);
    expect(find.text('M12345'), findsOneWidget);
    expect(find.text('123 Main St'), findsOneWidget);
    
    // Verify the tabs are displayed
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Consumption'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    
    // Tap on the Consumption tab
    await tester.tap(find.text('Consumption'));
    await tester.pumpAndSettle();
    
    // Verify consumption data is displayed
    expect(find.text('Water Consumption'), findsOneWidget);
    
    // Tap on the Payments tab
    await tester.tap(find.text('Payments'));
    await tester.pumpAndSettle();
    
    // Verify payment actions are displayed
    expect(find.text('Top Up'), findsOneWidget);
    expect(find.text('Pay Bill'), findsOneWidget);
  });

  testWidgets('Meter management - add new meter', (WidgetTester tester) async {
    // Mock empty meter list
    when(mockMeterService.getUserMeters()).thenAnswer((_) async => []);
    
    // Mock meter verification
    when(mockMeterService.processQRScanResult('INDOWATER:M12345')).thenAnswer((_) async => {
      'is_valid': true,
      'meter_number': 'M12345',
      'meter_data': {
        'id': '1',
        'meter_number': 'M12345',
        'status': 'active',
      },
    });
    
    // Mock meter registration
    when(mockMeterService.registerMeter(
      meterNumber: 'M12345',
      nickname: 'New Meter',
      address: '789 New St',
    )).thenAnswer((_) async => {
      'id': '1',
      'meter_number': 'M12345',
      'nickname': 'New Meter',
      'address': '789 New St',
      'status': 'active',
      'balance': 0.0,
      'last_reading': 0.0,
      'last_reading_date': null,
    });

    // Build our app wrapped with the mocked providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          Provider<ApiService>.value(value: mockApiService),
          Provider<MeterService>.value(value: mockMeterService),
        ],
        child: const app.MyApp(),
      ),
    );

    // Wait for splash screen and navigate to dashboard
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    
    // Navigate to meters screen
    await tester.tap(find.text('My Meters'));
    await tester.pumpAndSettle();
    
    // Tap on the add meter button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    
    // Verify we're on the add meter screen
    expect(find.text('Add Meter'), findsOneWidget);
    
    // Enter meter number
    await tester.enterText(find.byType(TextFormField).first, 'M12345');
    await tester.pump();
    
    // Tap the verify button
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    
    // Verify that the meter is verified
    expect(find.text('Meter Verified'), findsOneWidget);
    
    // Enter nickname and address
    await tester.enterText(find.byType(TextFormField).at(1), 'New Meter');
    await tester.enterText(find.byType(TextFormField).at(2), '789 New St');
    await tester.pump();
    
    // Tap the register button
    await tester.tap(find.text('Register Meter'));
    await tester.pumpAndSettle();
    
    // Verify that the meter is registered successfully
    expect(find.text('Meter Added Successfully!'), findsOneWidget);
  });

  testWidgets('Meter management - delete meter', (WidgetTester tester) async {
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
    
    // Mock meter details
    final mockMeterDetails = {
      'id': '1',
      'meter_number': 'M12345',
      'nickname': 'Home Meter',
      'address': '123 Main St',
      'status': 'active',
      'balance': 100.0,
      'last_reading': 50.0,
      'last_reading_date': '2023-01-01T00:00:00.000Z',
    };
    
    // Mock consumption and payment history
    when(mockMeterService.getMeterConsumptionHistory('1')).thenAnswer((_) async => []);
    when(mockMeterService.getMeterPaymentHistory('1')).thenAnswer((_) async => []);
    
    // Mock delete meter
    when(mockMeterService.deleteMeter('1')).thenAnswer((_) async => true);
    
    when(mockMeterService.getUserMeters()).thenAnswer((_) async => mockMeters);
    when(mockMeterService.getMeterDetails('1')).thenAnswer((_) async => mockMeterDetails);

    // Build our app wrapped with the mocked providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          Provider<ApiService>.value(value: mockApiService),
          Provider<MeterService>.value(value: mockMeterService),
        ],
        child: const app.MyApp(),
      ),
    );

    // Wait for splash screen and navigate to dashboard
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    
    // Navigate to meters screen
    await tester.tap(find.text('My Meters'));
    await tester.pumpAndSettle();
    
    // Tap on the first meter to view details
    await tester.tap(find.text('View Details').first);
    await tester.pumpAndSettle();
    
    // Tap on the more options button
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    
    // Tap on the delete option
    await tester.tap(find.text('Delete Meter'));
    await tester.pumpAndSettle();
    
    // Verify the confirmation dialog is shown
    expect(find.text('Delete Meter'), findsOneWidget);
    expect(find.text('Are you sure you want to delete this meter?'), findsOneWidget);
    
    // Tap the delete button
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    
    // Verify the meter is deleted and we're back on the meters screen
    verify(mockMeterService.deleteMeter('1')).called(1);
  });
}