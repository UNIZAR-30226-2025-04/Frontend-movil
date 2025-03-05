import 'package:flutter/material.dart';
import 'package:nogler/screens/home/home_screen.dart';
import 'package:nogler/screens/login/login_screen.dart';
import 'package:nogler/screens/info/info_screen.dart';
import 'package:nogler/utils/app_styles.dart';
import 'package:nogler/dio/dio_client.dart';
import 'package:nogler/widgets/background_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dio/dio.dart';

// This is the first screen that the user sees when opening the app
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key}); // Constructor for the class

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

// State class for WelcomeScreen
class _WelcomeScreenState extends State<WelcomeScreen> {
  final DioClient _dioClient = DioClient(); // Use the DioClient singleton

  // Method to check session status
  Future<void> _checkSessionAndNavigate() async {
    try {
      final response = await _dioClient.dio.get('/auth/me');

      if (response.statusCode == 200) {
        // If session is valid, navigate to HomeScreen
        if (mounted) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: const HomeScreen(),
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        debugPrint("🔒 No active session found. Redirecting to LoginScreen.");
        _navigateToLogin(); // If session is invalid, go to login
      } else {
        debugPrint("❌ Error checking session: ${e.message}");
        _navigateToLogin();
      }
    }
  }

  // Method to navigate to LoginScreen
  void _navigateToLogin() {
    if (mounted) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold widget to create the screen
      body: BackgroundWidget(
        // Background image for the screen
        child: SafeArea(
          // SafeArea widget to avoid overlapping with the system status bar
          child: Center(
            // Centers all elements horizontally and vertically
            child: Column(
              // Column widget to stack elements vertically
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centers all elements vertically
              children: [
                const SizedBox(height: 20), // Adds spacing at the top
                Image.asset(
                  'images/nogler.png',
                  width: 250,
                ), // Displays the logo image
                const SizedBox(height: 20), // Adds spacing between elements
                const Text(
                  // The text below the logo
                  'Welcome to Nogler an amazing\ncard game',
                  style:
                      AppStyles.subtitleStyle, // Uses a predefined text style
                  textAlign: TextAlign.center, // Centers the text
                ),

                // The two buttons on the screen
                SizedBox(
                  width: 200, // Sets a fixed width for the button
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button background color
                      foregroundColor: Colors.white, // Button text color
                    ),
                    onPressed: () {
                      // Check session before navigating
                      _checkSessionAndNavigate();
                    },
                    child: const Text('Start playing'), // Button label
                  ),
                ),
                const SizedBox(height: 16), // Adds spacing between buttons
                SizedBox(
                  width: 200, // Sets a fixed width for the button
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Button background color
                      foregroundColor: Colors.white, // Button text color
                    ),
                    onPressed: () {
                      // Navigates to InfoScreen when the button is pressed
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: const InfoScreen(),
                        ),
                      );
                    },
                    child: const Text('How to play'), // Button label
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
