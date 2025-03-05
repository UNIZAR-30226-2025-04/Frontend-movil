import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';

/// Singleton class for managing HTTP requests with Dio.
/// This ensures that the same Dio instance is used across the entire application.
class DioClient {
  static final DioClient _instance =
      DioClient._internal(); // Singleton instance
  late final Dio dio; // Dio instance for making API requests
  late final CookieJar _cookieJar; // CookieJar instance to manage cookies

  /// Factory constructor that returns the same instance every time.
  factory DioClient() {
    return _instance;
  }

  /// Private named constructor to initialize the singleton.
  DioClient._internal() {
    _cookieJar = CookieJar(); // Initialize CookieJar for handling cookies

    dio = Dio(
      BaseOptions(
        baseUrl: 'http://nogler.ddns.net:8080', // Base URL for API requests
        connectTimeout: const Duration(seconds: 10), // Set connection timeout
        receiveTimeout: const Duration(seconds: 10), // Set response timeout
        headers: {
          'Accept': 'application/json', // Default Accept header
          'Content-Type': 'application/json', // Default Content-Type header
        },
      ),
    );

    // Add CookieManager to automatically handle cookies across requests
    dio.interceptors.add(CookieManager(_cookieJar));

    // Add an interceptor to log requests, responses, and errors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
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

  /// Retrieves stored cookies for the base URL.
  ///
  /// This method fetches the cookies saved in the CookieJar for requests
  /// made to the API.
  ///
  /// Returns a `Future` containing a `List<Cookie>`.
  Future<List<Cookie>> getCookies() async {
    return _cookieJar.loadForRequest(Uri.parse('http://nogler.ddns.net:8080'));
  }

  /// Clears all stored cookies.
  ///
  /// This method is useful when the user logs out, ensuring that any stored
  /// session data is deleted.
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
    debugPrint("🚪 User logged out. Cookies cleared.");
  }
}
