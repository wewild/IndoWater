import 'package:flutter_test/flutter_test.dart';
import 'package:indowater_mobile/services/notification_service.dart';
import 'package:indowater_mobile/services/api_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'notification_service_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late NotificationService notificationService;

  setUp(() {
    mockApiService = MockApiService();
    notificationService = NotificationService(apiService: mockApiService);
  });

  group('NotificationService', () {
    test('getNotifications returns list of notifications', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'data': [
          {
            'id': '1',
            'title': 'Low Balance',
            'body': 'Your meter balance is low. Please top up soon.',
            'type': 'balance',
            'read': false,
            'created_at': '2023-01-01T00:00:00.000Z',
          },
          {
            'id': '2',
            'title': 'Payment Successful',
            'body': 'Your payment of $100 has been processed successfully.',
            'type': 'payment',
            'read': true,
            'created_at': '2023-01-02T00:00:00.000Z',
          },
        ],
      };

      when(mockApiService.get('/notifications')).thenAnswer((_) async => mockResponse);

      // Act
      final result = await notificationService.getNotifications();

      // Assert
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result[0]['title'], 'Low Balance');
      expect(result[1]['title'], 'Payment Successful');
    });

    test('markNotificationAsRead marks notification as read', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'data': {
          'id': '1',
          'title': 'Low Balance',
          'body': 'Your meter balance is low. Please top up soon.',
          'type': 'balance',
          'read': true,
          'created_at': '2023-01-01T00:00:00.000Z',
        },
      };

      when(mockApiService.put('/notifications/1/read', any)).thenAnswer((_) async => mockResponse);

      // Act
      final result = await notificationService.markNotificationAsRead('1');

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['read'], isTrue);
    });

    test('markAllNotificationsAsRead marks all notifications as read', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'message': 'All notifications marked as read',
      };

      when(mockApiService.put('/notifications/read-all', any)).thenAnswer((_) async => mockResponse);

      // Act
      final result = await notificationService.markAllNotificationsAsRead();

      // Assert
      expect(result, isTrue);
    });

    test('deleteNotification deletes a notification', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'message': 'Notification deleted successfully',
      };

      when(mockApiService.delete('/notifications/1')).thenAnswer((_) async => mockResponse);

      // Act
      final result = await notificationService.deleteNotification('1');

      // Assert
      expect(result, isTrue);
    });

    test('clearAllNotifications clears all notifications', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'message': 'All notifications cleared',
      };

      when(mockApiService.delete('/notifications/clear-all')).thenAnswer((_) async => mockResponse);

      // Act
      final result = await notificationService.clearAllNotifications();

      // Assert
      expect(result, isTrue);
    });

    test('getUnreadCount returns count of unread notifications', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'data': {
          'count': 5,
        },
      };

      when(mockApiService.get('/notifications/unread-count')).thenAnswer((_) async => mockResponse);

      // Act
      final result = await notificationService.getUnreadCount();

      // Assert
      expect(result, 5);
    });

    test('registerDeviceToken registers device token for push notifications', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'message': 'Device token registered successfully',
      };

      when(mockApiService.post('/notifications/register-device', any)).thenAnswer((_) async => mockResponse);

      // Act
      final result = await notificationService.registerDeviceToken('test-token');

      // Assert
      expect(result, isTrue);
    });

    test('unregisterDeviceToken unregisters device token', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'message': 'Device token unregistered successfully',
      };

      when(mockApiService.post('/notifications/unregister-device', any)).thenAnswer((_) async => mockResponse);

      // Act
      final result = await notificationService.unregisterDeviceToken('test-token');

      // Assert
      expect(result, isTrue);
    });

    test('initialize initializes notification service', () async {
      // This test is a placeholder since we can't actually test initialization in a unit test
      expect(notificationService.initialize(), completes);
    });
  });
}