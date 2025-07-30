import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:indowater_mobile/services/api_service.dart';

class MeterService {
  final ApiService _apiService;
  final Logger _logger = Logger();
  final MobileScannerController _scannerController = MobileScannerController();

  MeterService(this._apiService);

  // Get scanner controller
  MobileScannerController get scannerController => _scannerController;

  // Get user meters
  Future<List<Map<String, dynamic>>> getUserMeters() async {
    try {
      final response = await _apiService.get('/meters');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch user meters');
      }
      
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      _logger.e('Error fetching user meters: $e');
      throw Exception('Failed to fetch user meters: $e');
    }
  }

  // Get meter details
  Future<Map<String, dynamic>> getMeterDetails(String meterId) async {
    try {
      final response = await _apiService.get('/meters/$meterId');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch meter details');
      }
      
      return Map<String, dynamic>.from(response.data['data']);
    } catch (e) {
      _logger.e('Error fetching meter details: $e');
      throw Exception('Failed to fetch meter details: $e');
    }
  }

  // Register new meter
  Future<Map<String, dynamic>> registerMeter({
    required String meterNumber,
    required String address,
    String? nickname,
  }) async {
    try {
      final response = await _apiService.post(
        '/meters/register',
        data: {
          'meter_number': meterNumber,
          'address': address,
          'nickname': nickname,
        },
      );
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to register meter');
      }
      
      return Map<String, dynamic>.from(response.data['data']);
    } catch (e) {
      _logger.e('Error registering meter: $e');
      throw Exception('Failed to register meter: $e');
    }
  }

  // Update meter information
  Future<Map<String, dynamic>> updateMeter({
    required String meterId,
    String? nickname,
    String? address,
  }) async {
    try {
      final response = await _apiService.put(
        '/meters/$meterId',
        data: {
          'nickname': nickname,
          'address': address,
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update meter');
      }
      
      return Map<String, dynamic>.from(response.data['data']);
    } catch (e) {
      _logger.e('Error updating meter: $e');
      throw Exception('Failed to update meter: $e');
    }
  }

  // Delete meter
  Future<bool> deleteMeter(String meterId) async {
    try {
      final response = await _apiService.delete('/meters/$meterId');
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      _logger.e('Error deleting meter: $e');
      throw Exception('Failed to delete meter: $e');
    }
  }

  // Get meter consumption history
  Future<List<Map<String, dynamic>>> getMeterConsumptionHistory(String meterId) async {
    try {
      final response = await _apiService.get('/meters/$meterId/consumption');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch meter consumption history');
      }
      
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      _logger.e('Error fetching meter consumption history: $e');
      throw Exception('Failed to fetch meter consumption history: $e');
    }
  }

  // Get meter payment history
  Future<List<Map<String, dynamic>>> getMeterPaymentHistory(String meterId) async {
    try {
      final response = await _apiService.get('/meters/$meterId/payments');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch meter payment history');
      }
      
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      _logger.e('Error fetching meter payment history: $e');
      throw Exception('Failed to fetch meter payment history: $e');
    }
  }

  // Process QR code scan result
  Future<Map<String, dynamic>> processQRScanResult(String qrData) async {
    try {
      // Validate QR code format
      if (!qrData.startsWith('INDOWATER:')) {
        throw Exception('Invalid QR code format');
      }
      
      // Extract meter number from QR code
      final meterNumber = qrData.split(':')[1];
      
      // Verify meter number with API
      final response = await _apiService.post(
        '/meters/verify',
        data: {
          'meter_number': meterNumber,
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to verify meter');
      }
      
      return {
        'meter_number': meterNumber,
        'is_valid': response.data['is_valid'],
        'meter_data': response.data['data'],
      };
    } catch (e) {
      _logger.e('Error processing QR scan result: $e');
      throw Exception('Failed to process QR scan result: $e');
    }
  }

  // Submit meter reading
  Future<Map<String, dynamic>> submitMeterReading({
    required String meterId,
    required double reading,
    File? image,
  }) async {
    try {
      // Create form data
      final formData = {
        'reading': reading.toString(),
      };
      
      // Add image if available
      if (image != null) {
        final response = await _apiService.uploadFile(
          '/meters/$meterId/reading',
          formData: formData,
          file: image,
          fileField: 'image',
        );
        
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Failed to submit meter reading');
        }
        
        return Map<String, dynamic>.from(response.data['data']);
      } else {
        final response = await _apiService.post(
          '/meters/$meterId/reading',
          data: formData,
        );
        
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Failed to submit meter reading');
        }
        
        return Map<String, dynamic>.from(response.data['data']);
      }
    } catch (e) {
      _logger.e('Error submitting meter reading: $e');
      throw Exception('Failed to submit meter reading: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _scannerController.dispose();
  }
}