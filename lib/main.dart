import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/welcome/welcome_screen.dart';

// Main entry point of the application
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Initializes the Flutter binding
  // Hide the status bar and navigation bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([ // Locks the orientation to landscape
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const NoglerApp()); // Runs the NoglerApp widget
}

// Main application widget
class NoglerApp extends StatelessWidget {
  const NoglerApp({super.key}); // Constructor for the class

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // MaterialApp widget to create the app
      title: 'Nogler',
      debugShowCheckedModeBanner: false, // Disables the debug banner
      theme: ThemeData( // Defines the theme of the app
        primarySwatch: Colors.blue,
        fontFamily: 'PixelifySans',
      ),
      home: const WelcomeScreen(), // Sets the initial screen of the app
    );
  }
}

