import 'package:nogler/data/api/users_api.dart';
import 'package:nogler/dialogs/friends_dialogs.dart';
import 'package:nogler/dialogs/lobby_dialogs.dart';
import 'package:nogler/dialogs/party_dialog.dart';
import 'package:nogler/dialogs/profile_dialog.dart';
import 'package:nogler/screens/home/game_screen.dart';
import 'package:nogler/screens/home/join_lobby_screen.dart';

import 'package:flutter/material.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/background_widget.dart';
import 'package:page_transition/page_transition.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Home screen of the application
class _HomeScreenState extends State<HomeScreen> {
  String _username = "Loading...";
  int _avatar = 1;
  final WebSocketClient wsClient = WebSocketClient();
  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Obtain user profile information
  }

  /// Method to load the user profile information
  Future<void> _loadUserProfile() async {
    // Pass a callback to loadUserProfile
    loadUserProfile((String username, int avatar) {
      setState(() {
        _username = username; // Update the username
        _avatar = avatar; // Update the avatar
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // Scaffold widget to create the screen
      body: BackgroundWidget(
        // Background image for the screen
        child: SafeArea(
          // SafeArea widget to avoid overlapping with the system status bar
          child: Column(
            // Column widget to stack elements vertically
            children: [
              Padding(
                // Adds padding around the profile button
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  // Aligns the profile button to the top right
                  alignment: Alignment.topRight,
                  child: _buildProfileButton(context, _username),
                ),
              ),

              Expanded(
                // Expanded widget to take up the remaining space
                child: Center(
                  child: Image.asset('images/nogler.png', width: 250),
                ),
              ),

              Padding(
                // Adds padding around the menu buttons
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20,
                ),
                child: Container(
                  // Container to hold the menu buttons
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3454),
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                    border: Border.all(color: Colors.white), // Black border
                  ),
                  child: Wrap(
                    // Wrap widget to create a flow of buttons
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center, // Centers the buttons
                    children: [
                      _buildMenuButton(context, 'VS AI', () async {
                        await wsClient.initialize();
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: GameScreen(),
                            ),
                          );
                        }
                      }),

                      _buildMenuButton(context, 'JOIN', () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: JoinLobbyScreen(
                              hostName: _username,
                              hostAvatar: _avatar,
                            ),
                          ),
                        );
                      }),
                      _buildMenuButton(context, 'HOST', () {
                        showCreateLobbyButton(
                          context,
                          _username,
                          _avatar,
                        ); //TODO, decision de hacerlo por parametro o por peticion a back
                      }),
                      _buildMenuButton(context, 'PARTY', () {
                        showPartyList(context, _username);
                      }),
                      _buildMenuButton(context, 'FRIENDS', () {
                        showFriendsList(context, _username);
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget to create a menu button
  Widget _buildMenuButton(
    BuildContext context,
    String title,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 120,
      height: 50,
      child: ElevatedButton(
        // ElevatedButton widget for the menu button
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C3454),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ), // Rounded corners
          side: BorderSide(
            color: Colors.white,
            width: 1, // White border
          ),
        ),
        onPressed: onPressed, // Calls the provided function when pressed
        child: Text(
          // Text inside the button
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Widget to create the profile button
  Widget _buildProfileButton(BuildContext context, String username) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // Style of the button
        backgroundColor: const Color(0xFF2C3454),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.white,
            width: 1, // White border
          ),
        ), // Rounded edges
      ),
      onPressed: () async {
        // Function to execute when the button is pressed
        // Show the profile dialog and wait for the result
        final result = await showProfile(context, _username, _avatar);
        if (result == true) {
          _loadUserProfile(); // Reload the user profile
        }
      }, // Empty function for now
      child: Column(
        // Column to stack text and username box vertically
        mainAxisSize: MainAxisSize.min, // Minimize the size of the column
        children: [
          const Text(
            // Text inside the button
            "Profile",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(width: 8), // Space between text and username box
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ), // Padding inside the box
            decoration: BoxDecoration(
              color: const Color(0xFF2C3454),
              borderRadius: BorderRadius.circular(8), // Rounded corners
              border: Border.all(color: Colors.white), // Black border
            ),
            child: Text(
              // Username text inside the box
              username,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
