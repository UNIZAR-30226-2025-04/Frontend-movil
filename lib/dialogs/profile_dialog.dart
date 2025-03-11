import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nogler/screens/welcome/welcome_screen.dart';
import 'package:nogler/dio/dio_client.dart';
import 'package:nogler/widgets/build_avatar_image.dart';
import 'package:page_transition/page_transition.dart';

Future<bool> showProfile(
  BuildContext context,
  String currentUsername,
  int currentAvatar,
) async {
  final List<int> iconOptions = List.generate(8, (index) => index);

  final usernameController = TextEditingController(text: currentUsername);
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  int selectedIcon = currentAvatar;
  bool changesMade = false;

  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (
          BuildContext context,
          void Function(void Function()) setState,
        ) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Pop up border
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        //spacing: 50,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              final newIcon = await showIconPickerDialog(
                                context,
                                iconOptions,
                                selectedIcon,
                              );
                              if (newIcon != null) {
                                setState(() {
                                  selectedIcon = newIcon;
                                  changesMade = true;
                                });
                              }
                            },
                            child: CircleAvatar(
                              radius: 75,
                              backgroundColor: Colors.white,
                              child: buildAvatarImage(selectedIcon),
                            ),
                          ),
                          //make space between
                          SizedBox(width: 20),

                          Expanded(
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                _buildTextField('Username', usernameController),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  'Password',
                                  passwordController,
                                  isPassword: true,
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  'Repeat password',
                                  repeatPasswordController,
                                  isPassword: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              bool success = await _updateProfile(
                                usernameController.text,
                                passwordController.text,
                                repeatPasswordController.text,
                                selectedIcon,
                                context,
                              );

                              if (success) {
                                changesMade = true;
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              }
                            },
                            child: const Text('Save Changes'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            onPressed: () async {
                              await _logout(context);
                            },
                            child: const Text('Log off'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            onPressed: () {
                              if (context.mounted) {
                                Navigator.pop(
                                  context,
                                  changesMade,
                                ); // Close the dialog
                              }
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
  return result ?? false; // Return false if the dialog is dismissed
}

/// **Updates the user's profile information**
/// - Checks if `newPassword` and `repeatPassword` match before sending the request.
/// - If passwords don't match, it displays an error message.
/// - Returns `true` if the update is successful, otherwise returns `false`.
Future<bool> _updateProfile(
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

/// **Displays a pop-up for selecting an avatar icon**
/// - Shows a list of available icons.
/// - When the user selects an icon, it returns the corresponding integer.
Future<int?> showIconPickerDialog(
  BuildContext context,
  List<int> icons,
  int currentIcon,
) {
  return showDialog<int?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Choose Your Icon"),
        content: SizedBox(
          width: 400,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                icons.map((iconIndex) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, iconIndex);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: buildAvatarImage(iconIndex),
                        ),
                        const SizedBox(height: 5),
                        Text("Icon $iconIndex"),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  );
}

/// **Logs out the user by calling the `/auth/logout` API endpoint**
/// - Clears session cookies and redirects the user to the `WelcomeScreen`.
Future<void> _logout(BuildContext context) async {
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

/// **Reusable text field widget**
/// - Supports password input with `obscureText` option.
/// - Styled with a dark theme.
Widget _buildTextField(
  String label,
  TextEditingController controller, {
  bool isPassword = false,
}) {
  return TextField(
    controller: controller,
    obscureText: isPassword,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF353A50),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
