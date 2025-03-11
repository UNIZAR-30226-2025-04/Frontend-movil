import 'package:flutter/material.dart';
import 'package:nogler/dio/dio_client.dart';
import 'package:dio/dio.dart';

/// **Updates the user's profile information**
/// - Checks if `newPassword` and `repeatPassword` match before sending the request.
/// - If passwords don't match, it displays an error message.
/// - Returns `true` if the update is successful, otherwise returns `false`.
Future<bool> updateProfile(
  String newUsername,
  String newPassword,
  String repeatPassword,
  int newIcon,
  BuildContext context,
) async {
  final dioClient = DioClient();

  debugPrint("🔹 Updating Profile with:");
  debugPrint("   🟢 Username: $newUsername");
  debugPrint(
    "   🔵 New Password: ${newPassword.isNotEmpty ? '****' : '(No change)'}",
  );
  debugPrint(
    "   🟠 Repeat Password: ${repeatPassword.isNotEmpty ? '****' : '(No change)'}",
  );
  debugPrint("   🟣 Icon: $newIcon");
  // Validate if the new password matches the repeated password
  if (newPassword.isNotEmpty && newPassword != repeatPassword) {
    debugPrint("❌ Error: Passwords do not match.");

    // Show an error message in a small centered dialog
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            title: const Text(
              "Error",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            content: const Text(
              "Passwords do not match. Please try again.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close the dialog
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
    return false; // Stop the function if passwords do not match
  }

  try {
    final response = await dioClient.dio.patch(
      '/auth/update',
      data: {
        "username": newUsername,
        if (newPassword.isNotEmpty)
          "password": newPassword, // Only send password if provided
        "icon": newIcon, // Send the selected icon number
      },
      options: Options(
        // Options for the request
        contentType: Headers.formUrlEncodedContentType, // Set the content type
        responseType: ResponseType.json, // Set the response type
      ),
    );

    if (response.statusCode == 200) {
      debugPrint("✅ Profile updated successfully: ${response.data['message']}");
      return true;
    } else {
      debugPrint("❌ Failed to update profile: ${response.data}");
      return false;
    }
  } catch (e) {
    debugPrint("❌ Error updating profile: $e");
    return false;
  }
}
