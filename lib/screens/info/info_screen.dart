import 'package:flutter/material.dart';
import 'package:nogler/screens/info/info_cards_screen.dart';
import 'package:nogler/screens/info/info_compete_screen.dart';
import 'package:nogler/screens/info/info_friends_screen.dart';
import 'package:nogler/screens/info/info_shop_screen.dart';
import 'package:nogler/widgets/background_widget.dart';
import 'package:page_transition/page_transition.dart';

/// The screen that the user goes when they click on the "How to play" button
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold widget to create the screen
      body: BackgroundWidget(
        // Background image for the screen
        child: SafeArea(
          // SafeArea widget to avoid overlapping with the system status bar
          child: Padding(
            // Padding widget to add padding around the content
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              // Column widget to stack elements vertically
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    // Row widget to align elements horizontally
                    children: [
                      IconButton(
                        // Back button to navigate back to the previous screen
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                
                Wrap(
                  // Wrap widget to align elements in a grid
                  spacing: 16, // Horizontal spacing between buttons
                  runSpacing: 16, // Vertical spacing between buttons
                  alignment:
                      WrapAlignment.center, // Aligns the buttons in the center
                  children: [
                    // The four buttons on the screen

                    // Button to navigate to InfoCardsScreen
                    _buildMenuButton(context, 'Cards', () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: const InfoCardsScreen(),
                        ),
                      );
                    }),

                    // Button to navigate to InfoShopScreen
                    _buildMenuButton(context, 'Shop', () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: const InfoShopScreen(),
                        ),
                      );
                    }),

                    // Button to navigate to InfoFriendsScreen
                    _buildMenuButton(context, 'Friends', () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: const InfoFriendsScreen(),
                        ),
                      );
                    }),

                    // Button to navigate to InfoCompeteScreen
                    _buildMenuButton(context, 'Compete', () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: const InfoCompeteScreen(),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget to create a button with a title and an onPressed callback
  Widget _buildMenuButton(
    BuildContext context,
    String title,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      // SizedBox widget to set the size of the button
      width: MediaQuery.of(context).size.width * 0.4,
      height: 100, //
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Background color of the button
          foregroundColor: Colors.black, // Text color of the button
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ), // Padding inside the button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ), // Rounded corners
        ),
        onPressed: onPressed,
        child: Center(
          // Center widget to center the text inside the button
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
