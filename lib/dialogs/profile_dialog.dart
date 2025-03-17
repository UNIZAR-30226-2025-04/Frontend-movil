import 'package:flutter/material.dart';
import 'package:nogler/data/api/auth_api.dart';
import 'package:nogler/data/api/users_api.dart';
import 'package:nogler/widgets/build_avatar_image.dart';

/// Displays a dialog that allows the user to edit their profile.
/// This includes changing the username, password, and avatar.
/// Returns `true` if the changes were saved, and `false` if the dialog was canceled.
Future<bool> showProfile(
  BuildContext context,
  String currentUsername,
  int currentAvatar,
) async {
  // List of available icon options (avatars)
  final List<int> iconOptions = List.generate(8, (index) => index);

  // Text controllers for managing input fields for username and passwords
  final usernameController = TextEditingController(text: currentUsername);
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  // Initially selected avatar icon and a flag to track if changes were made
  int selectedIcon = currentAvatar;
  bool changesMade = false;

  // Display the dialog and wait for the result
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
                          // Avatar selection (gesture to pick new avatar)
                          GestureDetector(
                            onTap: () async {
                              // Hide the keyboard
                              FocusScope.of(context).unfocus();
                              // Show the icon picker dialog
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
                              child: buildAvatarImage(
                                selectedIcon - 1,
                              ), // Display selected avatar
                            ),
                          ),

                          // Add space between avatar and text fields
                          SizedBox(width: 20),

                          Expanded(
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                // Text field for username
                                _buildTextField('Username', usernameController),
                                const SizedBox(height: 8),
                                // Text field for password
                                _buildTextField(
                                  'Password',
                                  passwordController,
                                  isPassword: true,
                                ),
                                const SizedBox(height: 8),
                                // Text field for repeat password
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
                          // Save changes button
                          ElevatedButton(
                            onPressed: () async {
                              // Try updating the profile with new data
                              bool success = await updateProfile(
                                usernameController.text,
                                passwordController.text,
                                repeatPasswordController.text,
                                selectedIcon,
                                context,
                              );

                              if (success) {
                                changesMade =
                                    true; // Mark changes as successful
                                if (context.mounted) {
                                  Navigator.pop(
                                    context,
                                    true,
                                  ); // Close dialog and return true
                                }
                              }
                            },
                            child: const Text('Save Changes'),
                          ),
                          // Log off button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            onPressed: () async {
                              await logout(context);
                            },
                            child: const Text('Log off'),
                          ),
                          // Cancel button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            onPressed: () {
                              // Close the dialog without making any changes
                              if (context.mounted) {
                                Navigator.pop(
                                  context,
                                  changesMade, // Return whether changes were made
                                );
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
                          child: buildAvatarImage(iconIndex - 1),
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
