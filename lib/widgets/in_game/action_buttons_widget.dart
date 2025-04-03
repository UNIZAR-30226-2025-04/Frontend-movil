import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/game_fase/sort_options_widget.dart';

/// A widget that provides action buttons for the game.
/// It includes options to "Play Hand", "Sort Hand", and "Discard".
class ActionButtons extends StatelessWidget {
  final VoidCallback onDiscard;
  final VoidCallback onPlayHand;
  const ActionButtons({
    super.key,
    required this.onDiscard,
    required this.onPlayHand,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Button to play the current hand
        ElevatedButton(
          onPressed: onPlayHand,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, // Set text color to black
          ),
          child: Text("Play Hand"),
        ),
        SizedBox(width: 20),

        // Widget for sorting options (by Rank or Suit)
        SortOptions(),
        SizedBox(width: 20),

        // Button to discard a card
        ElevatedButton(
          onPressed: onDiscard,
          style: ElevatedButton.styleFrom(foregroundColor: Colors.black),
          child: Text("Discard"),
        ),
      ],
    );
  }
}
