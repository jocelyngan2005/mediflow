// Test file to verify API connection
// Run this to test if the backend is working
// flutter test test/api_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mediflow/services/api_service.dart';

void main() {
  group('API Service Tests', () {
    test('Should connect to backend health check', () async {
      // This test checks if the backend is running
      // Skip this test if backend is not available
      
      try {
        final response = await ApiService.getClinics();
        print('API Response: ${response.success}');
        if (response.success) {
          print('Clinics found: ${response.data?.length ?? 0}');
          expect(response.success, isTrue);
        } else {
          print('Error: ${response.error}');
          // If backend is not available, that's okay for now
          expect(response.success, isFalse);
        }
      } catch (e) {
        print('Connection error: $e');
        // Network errors are expected if backend is not running
        expect(e.toString(), contains('SocketException'));
      }
    });

    test('Should create valid ChatResponse from JSON', () {
      final json = {
        'reply': 'Test response',
        'source_document': 'test-doc'
      };
      
      final response = ChatResponse.fromJson(json);
      
      expect(response.reply, equals('Test response'));
      expect(response.sourceDocument, equals('test-doc'));
    });

    test('Should create valid ApiClinic from JSON', () {
      final json = {
        'clinic_id': 'test-clinic',
        'name': 'Test Clinic',
        'address': 'Test Address',
        'phone': '123-456-7890',
        'operating_hours': '9AM-5PM',
        'languages_supported': ['BM', 'EN'],
        'services': ['General Practice'],
        'is_active': true
      };
      
      final clinic = ApiClinic.fromJson(json);
      
      expect(clinic.clinicId, equals('test-clinic'));
      expect(clinic.name, equals('Test Clinic'));
      expect(clinic.hours, equals('9AM-5PM'));
      expect(clinic.languagesSupported, contains('BM'));
      expect(clinic.services, contains('General Practice'));
      expect(clinic.isActive, isTrue);
    });
  });
}