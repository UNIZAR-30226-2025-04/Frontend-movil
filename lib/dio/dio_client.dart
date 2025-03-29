import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Singleton class for managing HTTP requests with Dio.
/// This ensures that the same Dio instance is used across the entire application.
class DioClient {
  static final DioClient _instance =
      DioClient._internal(); // Singleton instance
  late final Dio dio; // Dio instance for making API requests
  final FlutterSecureStorage _storage =
      FlutterSecureStorage(); // Secure storage instance

  /// Factory constructor that returns the same instance every time.
  factory DioClient() {
    return _instance;
  }

  /// Private named constructor to initialize the singleton.
  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://nogler.ddns.net:443', // Base URL for API requests
        connectTimeout: const Duration(seconds: 10), // Set connection timeout
        receiveTimeout: const Duration(seconds: 10), // Set response timeout
        headers: {
          'Accept': 'application/json', // Default Accept header
          'Content-Type': 'application/json', // Default Content-Type header
        },
      ),
    );

    // Add an interceptor to handle JWT authentication and logging
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _addTokenToRequest(options); // Add token to request
          debugPrint("🚀 Sending Request: ${options.method} ${options.path}");
          return handler.next(options); // Continue with the request
        },
        onResponse: (response, handler) {
          debugPrint("✅ Response: ${response.statusCode} ${response.data}");
          return handler.next(response); // Continue processing the response
        },
        onError: (DioException e, handler) {
          final errorMessage =
              e.response?.data['error'] ?? 'Unknown error occurred';

          if (e.response == null) {
            debugPrint("❌ Error: ${e.message}");
          } else {
            debugPrint("❌ Error: $errorMessage");
          }
          return handler.next(e); // Continue error handling
        },
      ),
    );
  }

  /// Sets the JWT token for authentication.
  ///
  /// This method should be called after the user logs in successfully.
  Future<void> setToken(String token) async {
    await _storage.write(key: 'session_token', value: token); // Save the token securely
    debugPrint("🔑 JWT Token Set");
    try {
    final response = await _instance.dio.get('/auth/me');

    if (response.statusCode == 200) {
      String username = response.data['username'];

      // Store username
      await _storage.write(key: 'username', value: username);

      debugPrint("👤 User Profile Saved: $username");
    } else {
      debugPrint("❌ Error getting profile: ${response.data}");
    }
  } catch (e) {
    debugPrint("❌ Network error while getting profile: $e");
  }
  }

  /// Clears the JWT token when the user logs out.
  ///
  /// This ensures that the authorization header is no longer included in requests.
  // Clear the token on logout
  Future<void> clearToken() async {
    await _storage.delete(key: 'session_token'); // Remove token securely
    await _storage.delete(key: 'username');
    debugPrint("🚪 User logged out. Token cleared.");
  }

  /// Retrieve the token from secure storage
  Future<String?> getToken() async {
    return await _storage.read(key: 'session_token');
  }

  /// Add the JWT token to the request header
  Future<void> _addTokenToRequest(RequestOptions options) async {
    final token = await getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint("🛠 Added Token to Request: $token");
    } else {
      debugPrint("⚠ No token found, request sent without authorization.");
    }
  }

}
