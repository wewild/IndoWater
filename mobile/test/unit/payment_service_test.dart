import 'package:flutter_test/flutter_test.dart';
import 'package:indowater_mobile/services/payment_service.dart';
import 'package:indowater_mobile/services/api_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'payment_service_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late PaymentService paymentService;

  setUp(() {
    mockApiService = MockApiService();
    paymentService = PaymentService(apiService: mockApiService);
  });

  group('PaymentService', () {
    test('getPaymentHistory returns list of payments', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'data': [
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
        ],
      };

      when(mockApiService.get('/payments')).thenAnswer((_) async => mockResponse);

      // Act
      final result = await paymentService.getPaymentHistory();

      // Assert
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result[0]['title'], 'Top-up');
      expect(result[1]['title'], 'Bill Payment');
    });

    test('getPaymentDetails returns payment details', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'data': {
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
        },
      };

      when(mockApiService.get('/payments/1')).thenAnswer((_) async => mockResponse);

      // Act
      final result = await paymentService.getPaymentDetails('1');

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['title'], 'Top-up');
      expect(result['amount'], 100.0);
      expect(result['transaction_id'], 'TRX123456');
    });

    test('processTopup processes payment successfully', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'data': {
          'id': '3',
          'title': 'Top-up',
          'amount': 100.0,
          'status': 'success',
          'transaction_id': 'TRX789012',
        },
      };

      when(mockApiService.post('/payments/topup', any)).thenAnswer((_) async => mockResponse);

      // Act
      final result = await paymentService.processTopup(
        amount: 100.0,
        paymentMethod: 'credit_card',
      );

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], PaymentStatus.success);
      expect(result['transaction_id'], 'TRX789012');
    });

    test('processTopup handles pending payment', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'data': {
          'id': '3',
          'title': 'Top-up',
          'amount': 100.0,
          'status': 'pending',
          'transaction_id': 'TRX789012',
        },
      };

      when(mockApiService.post('/payments/topup', any)).thenAnswer((_) async => mockResponse);

      // Act
      final result = await paymentService.processTopup(
        amount: 100.0,
        paymentMethod: 'bank_transfer',
      );

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], PaymentStatus.pending);
      expect(result['transaction_id'], 'TRX789012');
    });

    test('processTopup handles failed payment', () async {
      // Arrange
      final mockResponse = {
        'success': false,
        'message': 'Payment failed',
      };

      when(mockApiService.post('/payments/topup', any)).thenAnswer((_) async => mockResponse);

      // Act
      final result = await paymentService.processTopup(
        amount: 100.0,
        paymentMethod: 'credit_card',
      );

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], PaymentStatus.failed);
      expect(result['error'], 'Payment failed');
    });

    test('initializeMidtrans initializes Midtrans SDK', () async {
      // This test is a placeholder since we can't actually test SDK initialization in a unit test
      expect(paymentService.initializeMidtrans(), completes);
    });

    test('initializeDoku initializes DOKU SDK', () async {
      // This test is a placeholder since we can't actually test SDK initialization in a unit test
      expect(paymentService.initializeDoku(), completes);
    });
  });
}