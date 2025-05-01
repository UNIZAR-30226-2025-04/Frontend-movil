import 'package:flutter/material.dart';
import 'package:nogler/data/api/auth_api.dart';
import 'package:nogler/screens/home/home_screen.dart';
import 'package:nogler/screens/register/register_screen.dart';
import 'package:nogler/utils/app_styles.dart';
import 'package:nogler/widgets/background_widget.dart';
import 'package:nogler/widgets/input_field_widget.dart';
import 'package:page_transition/page_transition.dart';

/// Screen for the login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  // Create the mutable state for this widget
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// The state of the login screen
class _LoginScreenState extends State<LoginScreen> {
  final _emailController =
      TextEditingController(); // Controller for the email input
  final _passwordController =
      TextEditingController(); // Controller for the password input
  String? _errorMessage; // Error message to show if the login fails

  /// Method to login the user
  Future<void> _login() async {
    // Unfocus the text fields to hide the keyboard
    FocusScope.of(context).unfocus();

    // Call the login function from auth_api.dart
    loginUser(
      _emailController.text,
      _passwordController.text,
      (String? error) {
        // Handle error
        setState(() {
          _errorMessage = error ?? 'An unknown error occurred.';
        });
      },
      (String successMessage) {
        // On success, navigate to the HomeScreen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageTransition(
              duration: const Duration(milliseconds: 300),
              type: PageTransitionType.fade,
              child: const HomeScreen(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth =
        MediaQuery.of(context).size.width; // Get the screen width
    double screenHeight =
        MediaQuery.of(context).size.height; // Get the screen height
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Allow the screen to resize when the keyboard appears
      body: GestureDetector(
        // GestureDetector to handle gestures
        onTap: () {
          FocusScope.of(
            context,
          ).unfocus(); // Unfocus the text fields when the user taps outside
        },
        child: BackgroundWidget(
          // Background image for the screen
          child: SafeArea(
            // SafeArea widget to avoid overlapping with the system status bar
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
                // Login box
                Center(
                  child: ConstrainedBox(
                    // ConstrainedBox to limit the size of the login box
                    constraints: BoxConstraints(
                      // BoxConstraints to limit the size of the login box
                      maxWidth:
                          screenWidth *
                          0.8, // Ensures login box doesn't exceed 80% of screen width
                      maxHeight: screenHeight, // Adjusts height dynamically
                    ),
                    child: SingleChildScrollView(
                      // Wrap the Stack with a SingleChildScrollView to make it scrollable when keyboard appears
                      child: Container(
                        // Container for the login box
                        width: 380,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ), // Reduced vertical padding
                        decoration: BoxDecoration(
                          // BoxDecoration widget to add decoration to the container
                          color: Color.fromARGB(
                            127,
                            128,
                            128,
                            128,
                          ), // Sets a semi-transparent background
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Column(
                          // Column widget to organize the elements vertically
                          mainAxisSize:
                              MainAxisSize
                                  .min, // Minimize the size of the column
                          //
                          children: [
                            const Text(
                              // Text widget to display text
                              'Login',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ), // Reduced height from 16 to 10

                            if (_errorMessage !=
                                null) // Show the error message if it exists
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 4,
                                ), // Reduced padding from 8 to 4
                                child: Text(
                                  _errorMessage!, // Show the error message
                                  style: const TextStyle(
                                    color: AppStyles.errorColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                            // Input fields for the email and password
                            InputFieldWidget(
                              label: 'Email',
                              controller: _emailController,
                              isPassword: false,
                              size: 85,
                            ),
                            const SizedBox(height: 8),
                            InputFieldWidget(
                              label: 'Password',
                              controller: _passwordController,
                              isPassword: true,
                              size: 85,
                            ),

                            const SizedBox(height: 12),

                            Row(
                              // Row widget to organize the elements horizontally
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center, // Center the elements horizontally
                              children: [
                                TextButton(
                                  // TextButton widget to create a button with text
                                  onPressed: () {
                                    // Navigates to RegisterScreen when the button is pressed
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.fade,
                                        child: const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: AppStyles.primaryColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 40),
                                // Button to login
                                ElevatedButton(
                                  // ElevatedButton widget to create a button with elevation
                                  style: AppStyles.acceptButtonStyle,
                                  onPressed: _login,
                                  child: const Text('Login'),
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
    );
  }
}
