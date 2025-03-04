import 'package:flutter/material.dart';
import 'package:nogler/utils/app_styles.dart';
import 'package:nogler/widgets/background_widget.dart';
import 'package:nogler/widgets/input_field_widget.dart';

// Screen for user registration
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key}); // Constructor for the register screen

  // Create the mutable state for this widget
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// The state of the register screen
class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController =
      TextEditingController(); // Controller for email input
  final _passwordController =
      TextEditingController(); // Controller for password input
  final _repeatPasswordController =
      TextEditingController(); // Controller for repeat password input
  final _usernameController =
      TextEditingController(); // Controller for username input

  String? _errorMessage; // Stores error message if registration fails

  // Method to register the user
  void _register() {
    // Check if passwords match
    if (_passwordController.text != _repeatPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    // Mock validation for existing user
    if (_emailController.text == 'jorge@gmail.com') {
      setState(() {
        _errorMessage = 'User already exists';
      });
      return;
    }

    // Navigate to the login screen after successful registration
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width
    double screenHeight =
        MediaQuery.of(context).size.height; // Get screen height

    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Allows screen to adjust when keyboard appears
      body: GestureDetector(
        // GestureDetector to handle gestures
        onTap:
            () =>
                FocusScope.of(
                  context,
                ).unfocus(), // Hides keyboard when tapping outside
        child: BackgroundWidget(
          // Background image for the screen
          child: SafeArea(
            // SafeArea widget to avoid overlapping with the system status bar
            child: Center(
              // Centers all elements horizontally and vertically
              child: Stack(
                // Stack widget to stack elements on top of each other
                children: [
                  // Displays the logo image
                  Positioned(
                    top: 39.9,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        'images/nogler.png',
                        width: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Registration form container
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        // BoxConstraints to limit the size of the login box
                        maxWidth:
                            screenWidth *
                            0.8, // Limits register box width to 80% of screen width
                        maxHeight: screenHeight, // Dynamically adjusts height
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          width: 500,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(
                              0.5,
                            ), // Sets a semi-transparent background
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Adds rounded corners
                            border: Border.all(color: Colors.black),
                          ),
                          child: Column(
                            // Column widget to organize the elements vertically
                            mainAxisSize:
                                MainAxisSize
                                    .min, // Minimize the size of the column
                            children: [
                              const Text(
                                // Text widget to display text
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),

                              // Display error message if exists
                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: AppStyles.errorColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),

                              // Input fields for registration
                              InputFieldWidget(
                                label: 'Email',
                                controller: _emailController,
                                isPassword: false,
                                size: 200,
                              ),
                              const SizedBox(height: 8),
                              InputFieldWidget(
                                label: 'Password',
                                controller: _passwordController,
                                isPassword: true,
                                size: 200,
                              ),
                              const SizedBox(height: 8),
                              InputFieldWidget(
                                label: 'Repeat your password',
                                controller: _repeatPasswordController,
                                isPassword: true,
                                size: 200,
                              ),
                              const SizedBox(height: 8),
                              InputFieldWidget(
                                label: 'Username',
                                controller: _usernameController,
                                isPassword: false,
                                size: 200,
                              ),

                              const SizedBox(height: 12),

                              Row(
                                // Row widget to organize the elements horizontally
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center, // Center the elements horizontally
                                children: [
                                  // Cancel button
                                  ElevatedButton(
                                    // ElevatedButton widget to create a button
                                    style: AppStyles.cancelButtonStyle,
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: 40),

                                  // Register button
                                  ElevatedButton(
                                    // ElevatedButton widget to create a button
                                    style: AppStyles.acceptButtonStyle,
                                    onPressed: _register,
                                    child: const Text('Accept'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
