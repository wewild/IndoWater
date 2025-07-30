import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:logger/logger.dart';
import 'package:indowater_mobile/services/api_service.dart';
import 'package:indowater_mobile/utils/constants.dart';

enum PaymentStatus {
  pending,
  success,
  failed,
  canceled,
}

class PaymentService {
  final ApiService _apiService;
  final Logger _logger = Logger();
  MidtransSDK? _midtransSDK;
  bool _isInitialized = false;

  PaymentService(this._apiService);

  // Initialize Midtrans SDK
  Future<void> initializeMidtrans() async {
    if (_isInitialized) return;

    try {
      _midtransSDK = await MidtransSDK.init(
        config: MidtransConfig(
          clientKey: Constants.midtransClientKey,
          merchantBaseUrl: Constants.midtransMerchantBaseUrl,
          colorTheme: ColorTheme(
            colorPrimary: Colors.blue,
            colorPrimaryDark: Colors.blue.shade700,
            colorSecondary: Colors.blue.shade500,
          ),
        ),
      );

      _midtransSDK?.setUIKitCustomization(
        skipCustomization: false,
        showPaymentStatus: true,
      );

      _midtransSDK?.setTransactionFinishedCallback((result) {
        _logger.i('Transaction Finished: ${result.toJson()}');
        // Handle transaction result
      });

      _isInitialized = true;
      _logger.i('Midtrans SDK initialized successfully');
    } catch (e) {
      _logger.e('Error initializing Midtrans SDK: $e');
      throw Exception('Failed to initialize payment gateway: $e');
    }
  }

  // Process payment with Midtrans
  Future<Map<String, dynamic>> processPayment({
    required String orderId,
    required double amount,
    required String itemName,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    try {
      await initializeMidtrans();

      // Create transaction token from backend
      final response = await _apiService.post(
        '/payments/create-token',
        data: {
          'order_id': orderId,
          'amount': amount,
          'item_name': itemName,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_phone': customerPhone,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create payment token');
      }

      final String token = response.data['token'];
      
      // Start payment UI
      final paymentResult = await _midtransSDK?.startPaymentUiFlow(token: token);
      
      if (paymentResult == null) {
        throw Exception('Payment process was interrupted');
      }

      // Process payment result
      return {
        'status': _getPaymentStatus(paymentResult.transactionStatus),
        'transaction_id': paymentResult.transactionId,
        'order_id': paymentResult.orderId,
        'payment_type': paymentResult.paymentType,
        'transaction_time': paymentResult.transactionTime,
        'transaction_status': paymentResult.transactionStatus,
        'gross_amount': paymentResult.grossAmount,
      };
    } catch (e) {
      _logger.e('Error processing payment: $e');
      return {
        'status': PaymentStatus.failed,
        'error': e.toString(),
      };
    }
  }

  // Get payment status from transaction status
  PaymentStatus _getPaymentStatus(String? transactionStatus) {
    switch (transactionStatus?.toLowerCase()) {
      case 'capture':
      case 'settlement':
      case 'success':
        return PaymentStatus.success;
      case 'pending':
        return PaymentStatus.pending;
      case 'deny':
      case 'expire':
      case 'failure':
      case 'failed':
        return PaymentStatus.failed;
      case 'cancel':
      case 'canceled':
        return PaymentStatus.canceled;
      default:
        return PaymentStatus.failed;
    }
  }

  // Get payment history
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final response = await _apiService.get('/payments/history');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch payment history');
      }
      
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      _logger.e('Error fetching payment history: $e');
      throw Exception('Failed to fetch payment history: $e');
    }
  }

  // Get payment details
  Future<Map<String, dynamic>> getPaymentDetails(String paymentId) async {
    try {
      final response = await _apiService.get('/payments/$paymentId');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch payment details');
      }
      
      return Map<String, dynamic>.from(response.data['data']);
    } catch (e) {
      _logger.e('Error fetching payment details: $e');
      throw Exception('Failed to fetch payment details: $e');
    }
  }

  // Process topup payment
  Future<Map<String, dynamic>> processTopup({
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final String orderId = 'TOPUP-${DateTime.now().millisecondsSinceEpoch}';
      
      return await processPayment(
        orderId: orderId,
        amount: amount,
        itemName: 'IndoWater Topup',
        customerName: 'User', // This should be replaced with actual user data
        customerEmail: 'user@example.com', // This should be replaced with actual user data
        customerPhone: '08123456789', // This should be replaced with actual user data
      );
    } catch (e) {
      _logger.e('Error processing topup: $e');
      return {
        'status': PaymentStatus.failed,
        'error': e.toString(),
      };
    }
  }

  // Process bill payment
  Future<Map<String, dynamic>> processBillPayment({
    required String billId,
    required double amount,
    required String meterNumber,
  }) async {
    try {
      final String orderId = 'BILL-$billId-${DateTime.now().millisecondsSinceEpoch}';
      
      return await processPayment(
        orderId: orderId,
        amount: amount,
        itemName: 'Water Bill Payment - Meter $meterNumber',
        customerName: 'User', // This should be replaced with actual user data
        customerEmail: 'user@example.com', // This should be replaced with actual user data
        customerPhone: '08123456789', // This should be replaced with actual user data
      );
    } catch (e) {
      _logger.e('Error processing bill payment: $e');
      return {
        'status': PaymentStatus.failed,
        'error': e.toString(),
      };
    }
  }

  // Dispose resources
  void dispose() {
    _midtransSDK?.removeTransactionFinishedCallback();
  }
}