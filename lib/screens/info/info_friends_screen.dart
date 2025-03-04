import 'package:flutter/material.dart';
import 'package:nogler/widgets/background_widget.dart';

// Screen that shows the rules of the friend system
class InfoFriendsScreen extends StatelessWidget {
  const InfoFriendsScreen({super.key});
  // The build method is used to describe how to display the widget on the screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold widget to create the screen
      body: BackgroundWidget(
        // Background image for the screen
        child: SafeArea(
          // SafeArea widget to avoid the status bar
          child: Column(
            // Column widget to organize the screen vertically
            children: [
              Padding(
                // Padding widget to add space around the row
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  // Row widget to organize the elements horizontally
                  children: [
                    IconButton(
                      // IconButton widget to create a button with an icon
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(), // Spacer widget to add space between elements
                    const Text(
                      // Text widget to display text
                      'Friends',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(), // Spacer widget to add space between elements
                    const SizedBox(
                      width: 48,
                    ), // SizedBox widget to add space between elements
                  ],
                ),
              ),
              Expanded(
                // Expanded widget to fill the available space
                child: Center(
                  // Center widget to center the container
                  child: Container(
                    // Container widget to create a container
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.6,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // BoxDecoration widget to add decoration to the container
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Border radius of the container
                    ),
                    child: const Center(
                      // Center widget to center the text
                      child: Text(
                        // Text widget to display text
                        'Explanation of the friend system.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
