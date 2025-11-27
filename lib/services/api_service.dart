import 'dart:convert';
import 'package:http/http.dart' as http;

/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse.success(this.data)
      : success = true,
        error = null;

  ApiResponse.error(this.error)
      : success = false,
        data = null;
}

/// Chat response model
class ChatResponse {
  final String reply;
  final String? sourceDocument;

  ChatResponse({
    required this.reply,
    this.sourceDocument,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      reply: json['reply'] ?? '',
      sourceDocument: json['source_document'],
    );
  }
}

/// Clinic model for API responses
class ApiClinic {
  final String clinicId;
  final String name;
  final String address;
  final String phone;
  final String? email;
  final String operatingHours;
  final List<String> languagesSupported;
  final List<String> services;
  final bool isActive;

  ApiClinic({
    required this.clinicId,
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    required this.operatingHours,
    required this.languagesSupported,
    required this.services,
    required this.isActive,
  });

  factory ApiClinic.fromJson(Map<String, dynamic> json) {
    return ApiClinic(
      clinicId: json['clinic_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      operatingHours: json['operating_hours'] ?? '',
      languagesSupported: List<String>.from(json['languages_supported'] ?? []),
      services: List<String>.from(json['services'] ?? []),
      isActive: json['is_active'] ?? true,
    );
  }

  // For backward compatibility with existing Clinic class
  String get hours => operatingHours;
}

class ApiService {
  // Update this to your backend URL
  // Use localhost with ADB reverse port forwarding for physical devices
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const String staffSecretCode = 'MEDIFLOW-ADMIN-2024';

  /// Get available clinics
  static Future<ApiResponse<List<ApiClinic>>> getClinics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clinics'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Backend returns array directly, not wrapped in 'clinics' field
        final List<ApiClinic> clinics = (data as List?)
                ?.map((clinic) => ApiClinic.fromJson(clinic))
                .toList() ??
            [];
        return ApiResponse.success(clinics);
      } else {
        return ApiResponse.error('Failed to load clinics: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Unified chat method for both FAQ and SOP questions
  static Future<ApiResponse<ChatResponse>> sendChatMessage({
    required String clinicId,
    required String message,
    required String language,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/patients/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'clinic_id': clinicId,
          'message': message,
          'language': language,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final chatResponse = ChatResponse.fromJson(data);
        return ApiResponse.success(chatResponse);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(errorData['detail'] ?? 'Chat request failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Send FAQ chat message using clinic-specific SOPs (Legacy method)
  static Future<ApiResponse<ChatResponse>> sendFaqMessage({
    required String clinicId,
    required String message,
    required String language,
  }) async {
    // Redirect to unified chat endpoint
    return sendChatMessage(
      clinicId: clinicId,
      message: message,
      language: language,
    );
  }

  /// Search PDF/SOP documents (Legacy method - redirects to unified chat)
  static Future<ApiResponse<ChatResponse>> searchDocuments({
    required String clinicId,
    required String query,
    required String language,
  }) async {
    // Redirect to unified chat endpoint
    return sendChatMessage(
      clinicId: clinicId,
      message: query,
      language: language,
    );
  }

  /// Book appointment (Action Table A: Appointment Booking)
  static Future<ApiResponse<ChatResponse>> bookAppointment({
    required String clinicId,
    required String message,
    required String language,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/patients/appointment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'clinic_id': clinicId,
          'message': message,
          'language': language,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final chatResponse = ChatResponse.fromJson(data);
        return ApiResponse.success(chatResponse);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(errorData['detail'] ?? 'Appointment booking failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Send staff chat message for medication lookup
  static Future<ApiResponse<Map<String, dynamic>>> sendStaffChatMessage({
    required String clinicId,
    required String message,
    required String language,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/staff/medication-lookup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'clinic_id': clinicId,
          'query': message,
          'language': language,
          'secret_code': staffSecretCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(data);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(errorData['detail'] ?? 'Staff query failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
}