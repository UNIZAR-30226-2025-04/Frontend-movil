import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Singleton class for managing HTTP requests with Dio.
/// This ensures that the same Dio instance is used across the entire application.
class DioClient {
  static final DioClient _instance =
      DioClient._internal(); // Singleton instance
  late final Dio dio; // Dio instance for making API requests
  String? _jwtToken; // JWT token to be used for authentication

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
        onRequest: (options, handler) { // Interceptor for requests
          if (_jwtToken != null) { // Add JWT token to Authorization header
            options.headers['Authorization'] = 'Bearer $_jwtToken';
          }
          debugPrint("🚀 Sending Request: ${options.method} ${options.path}");
          return handler.next(options); // Continue with the request
        },
        onResponse: (response, handler) {
          debugPrint("✅ Response: ${response.statusCode} ${response.data}");
          return handler.next(response); // Continue processing the response
        },
        onError: (DioException e, handler) {
          debugPrint("❌ Error: ${e.message}");
          return handler.next(e); // Continue error handling
        },
      ),
    );
  }

  /// Sets the JWT token for authentication.
  ///
  /// This method should be called after the user logs in successfully.
  void setToken(String token) {
    _jwtToken = token;
    debugPrint("🔑 JWT Token Set");
  }

  /// Clears the JWT token when the user logs out.
  ///
  /// This ensures that the authorization header is no longer included in requests.
  void clearToken() {
    _jwtToken = null;
    debugPrint("🚪 User logged out. Token cleared.");
  }
}
