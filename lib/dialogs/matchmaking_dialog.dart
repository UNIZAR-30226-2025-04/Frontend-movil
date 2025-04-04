import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nogler/data/api/join_lobby_api.dart';
import 'package:nogler/data/api/party_api.dart';
import 'package:nogler/screens/lobby/lobby_screen.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:page_transition/page_transition.dart';

/// Displays a matchmaking dialog with an animated dot loading indicator.
Future<void> showMatchmakingDialog(
  BuildContext context,
  String username,
  int iconId,
) async {
  bool hasFetched = false;
  final WebSocketClient wsClient =
      WebSocketClient(); // WebSocket client instance
  showDialog(
    context: context,
    builder: (BuildContext context) {
      if (!hasFetched) {
        hasFetched = true;
        Future.delayed(Duration.zero, () async {
          await Future.delayed(
            const Duration(seconds: 3),
          ); // Simulate loading time
          // Fetch a lobby ID from the API
          final lobbyId = await getLobby(); // Function to fetch a lobby
          if (context.mounted && lobbyId.isNotEmpty) {
            final public = await joinLobby(lobbyId);
            // Store the code in secure storage
            await const FlutterSecureStorage().write(key: 'code', value: lobbyId);
            // Auto-connect when screen loads
            await wsClient.initialize();
            if (context.mounted) {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: LobbyScreen(
                    hostName: username,
                    hostAvatar: iconId,
                    lobbyState: !public,
                    lobbyCode: lobbyId,
                  ),
                ),
              );
            }
          } else if (context.mounted) {
            Navigator.pop(context); // Close the dialog
          }
        });
      }
      return AlertDialog(
        backgroundColor: Colors.blueGrey[900], // Dark theme background
        title: const Text(
          "Matchmaking", // Dialog title
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Avoids unnecessary space
          children: [
            const SizedBox(height: 20),
            const AnimatedDots(), // Loading animation
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // White button
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 40,
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                ), // Black text on white button
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Animated widget that displays three dots changing size in place, simulating motion.
class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});

  @override
  AnimatedDotsState createState() => AnimatedDotsState();
}

class AnimatedDotsState extends State<AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _sizeAnimations;

  @override
  void initState() {
    super.initState();

    // Animation controller for synchronized dot size changes
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900), // Smooth animation speed
      vsync: this,
    )..repeat(reverse: true); // Repeats the animation back and forth

    // Size animations for each dot, creating a pulsating effect
    _sizeAnimations = List.generate(3, (index) {
      return TweenSequence<double>([
        if (index == 0) // First dot starts small, grows, then shrinks
        ...[
          TweenSequenceItem(
            tween: Tween(begin: 7.0, end: 10.0),
            weight: 1,
          ), // Small to Medium
          TweenSequenceItem(
            tween: Tween(begin: 10.0, end: 18.0),
            weight: 1,
          ), // Medium to Large
          TweenSequenceItem(
            tween: Tween(begin: 18.0, end: 10.0),
            weight: 1,
          ), // Large to Medium
          TweenSequenceItem(
            tween: Tween(begin: 10.0, end: 7.0),
            weight: 1,
          ), // Medium to Small
        ] else if (index ==
            1) // Middle dot moves differently to create variation
        ...[
          TweenSequenceItem(
            tween: Tween(begin: 10.0, end: 18.0),
            weight: 1,
          ), // Medium to Large
          TweenSequenceItem(
            tween: Tween(begin: 18.0, end: 10.0),
            weight: 1,
          ), // Large to Medium
          TweenSequenceItem(
            tween: Tween(begin: 10.0, end: 18.0),
            weight: 1,
          ), // Medium to Large
          TweenSequenceItem(
            tween: Tween(begin: 18.0, end: 10.0),
            weight: 1,
          ), // Large to Medium
        ] else // Last dot shrinks first, then grows (opposite to first dot)
        ...[
          TweenSequenceItem(
            tween: Tween(begin: 18.0, end: 10.0),
            weight: 1,
          ), // Large to Medium
          TweenSequenceItem(
            tween: Tween(begin: 10.0, end: 7.0),
            weight: 1,
          ), // Medium to Small
          TweenSequenceItem(
            tween: Tween(begin: 7.0, end: 10.0),
            weight: 1,
          ), // Small to Medium
          TweenSequenceItem(
            tween: Tween(begin: 10.0, end: 18.0),
            weight: 1,
          ), // Medium to Large
        ],
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.linear, // Smooth transitions
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              double size =
                  _sizeAnimations[index]
                      .value; // Each dot has a different size change pattern

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white, // Dots are white
                  borderRadius: BorderRadius.circular(
                    size * 0.4,
                  ), // Dynamic border radius for smooth appearance
                ),
              );
            }),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Properly dispose of the animation controller
    super.dispose();
  }
}
