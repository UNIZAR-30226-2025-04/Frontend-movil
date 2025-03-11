import 'package:flutter/material.dart';
import 'package:nogler/dio/dio_client.dart';
import 'package:nogler/screens/welcome/welcome_screen.dart';
import 'package:page_transition/page_transition.dart';

/// **Logs out the user by calling the `/auth/logout` API endpoint**
/// - Clears session cookies and redirects the user to the `WelcomeScreen`.
Future<void> logout(BuildContext context) async {
  final dioClient = DioClient(); // Get the singleton DioClient instance

  try {
    // Send a DELETE request to `/auth/logout` to end the user session
    final response = await dioClient.dio.delete('/auth/logout');

    // If the request was successful (status code 200)
    if (response.statusCode == 200) {
      debugPrint("✅ Logout successful: ${response.data['message']}");

      // Clear all stored cookies to ensure the session is completely ended
      dioClient.clearToken();

      // Navigate to `WelcomeScreen` and remove all previous routes
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: const WelcomeScreen(),
          ),
          (route) =>
              false, // Remove all previous screens from the navigation stack
        );
      }
    } else {
      debugPrint("❌ Failed to log out: ${response.data}");
    }
  } catch (e) {
    // Handle any network errors or unexpected failures
    debugPrint("❌ Error during logout: $e");
  }
}
