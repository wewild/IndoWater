import 'package:flutter_test/flutter_test.dart';
import 'package:indowater_mobile/services/meter_service.dart';
import 'package:indowater_mobile/services/api_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'meter_service_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late MeterService meterService;

  setUp(() {
    mockApiService = MockApiService();
    meterService = MeterService(apiService: mockApiService);
  });

  group('MeterService', () {
    test('getUserMeters returns list of meters', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'data': [
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
        ],
      };

      when(mockApiService.get('/meters')).thenAnswer((_) async => mockResponse);

      // Act
      final result = await meterService.getUserMeters();

      // Assert
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result[0]['meter_number'], 'M12345');
      expect(result[1]['meter_number'], 'M67890');
    });

    test('getMeterDetails returns meter details', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'data': {
          'id': '1',
          'meter_number': 'M12345',
          'nickname': 'Home Meter',
          'address': '123 Main St',
          'status': 'active',
          'balance': 100.0,
          'last_reading': 50.0,
          'last_reading_date': '2023-01-01T00:00:00.000Z',
        },
      };

      when(mockApiService.get('/meters/1')).thenAnswer((_) async => mockResponse);

      // Act
      final result = await meterService.getMeterDetails('1');

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['meter_number'], 'M12345');
      expect(result['balance'], 100.0);
    });

    test('getMeterConsumptionHistory returns consumption history', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'data': [
          {
            'id': '1',
            'meter_id': '1',
            'reading': 50.0,
            'value': 10.0,
            'date': '2023-01-01T00:00:00.000Z',
          },
          {
            'id': '2',
            'meter_id': '1',
            'reading': 60.0,
            'value': 10.0,
            'date': '2023-01-02T00:00:00.000Z',
          },
        ],
      };

      when(mockApiService.get('/meters/1/consumption')).thenAnswer((_) async => mockResponse);

      // Act
      final result = await meterService.getMeterConsumptionHistory('1');

      // Assert
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result[0]['reading'], 50.0);
      expect(result[1]['reading'], 60.0);
    });

    test('getMeterPaymentHistory returns payment history', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'data': [
          {
            'id': '1',
            'meter_id': '1',
            'amount': 50.0,
            'status': 'success',
            'date': '2023-01-01T00:00:00.000Z',
          },
          {
            'id': '2',
            'meter_id': '1',
            'amount': 100.0,
            'status': 'success',
            'date': '2023-01-02T00:00:00.000Z',
          },
        ],
      };

      when(mockApiService.get('/meters/1/payments')).thenAnswer((_) async => mockResponse);

      // Act
      final result = await meterService.getMeterPaymentHistory('1');

      // Assert
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result[0]['amount'], 50.0);
      expect(result[1]['amount'], 100.0);
    });

    test('registerMeter registers a new meter', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'data': {
          'id': '3',
          'meter_number': 'M12345',
          'nickname': 'New Meter',
          'address': '789 New St',
          'status': 'active',
          'balance': 0.0,
          'last_reading': 0.0,
          'last_reading_date': null,
        },
      };

      when(mockApiService.post('/meters', any)).thenAnswer((_) async => mockResponse);

      // Act
      final result = await meterService.registerMeter(
        meterNumber: 'M12345',
        nickname: 'New Meter',
        address: '789 New St',
      );

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['meter_number'], 'M12345');
      expect(result['nickname'], 'New Meter');
    });

    test('deleteMeter deletes a meter', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'message': 'Meter deleted successfully',
      };

      when(mockApiService.delete('/meters/1')).thenAnswer((_) async => mockResponse);

      // Act
      final result = await meterService.deleteMeter('1');

      // Assert
      expect(result, isTrue);
    });

    test('processQRScanResult processes valid QR code', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'data': {
          'id': '1',
          'meter_number': 'M12345',
          'status': 'active',
        },
      };

      when(mockApiService.post('/meters/verify', any)).thenAnswer((_) async => mockResponse);

      // Act
      final result = await meterService.processQRScanResult('INDOWATER:M12345');

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['is_valid'], isTrue);
      expect(result['meter_number'], 'M12345');
    });

    test('processQRScanResult handles invalid QR code', () async {
      // Arrange
      final mockResponse = {
        'success': false,
        'message': 'Invalid meter number',
      };

      when(mockApiService.post('/meters/verify', any)).thenAnswer((_) async => mockResponse);

      // Act
      final result = await meterService.processQRScanResult('INVALID:CODE');

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['is_valid'], isFalse);
    });
  });
}