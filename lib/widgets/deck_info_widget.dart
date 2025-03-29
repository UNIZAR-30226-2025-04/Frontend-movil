import 'package:flutter/material.dart';

/// A widget that displays deck information with a stack of cards and the card count.
/// The count updates when the widget is tapped.
class DeckInfo extends StatefulWidget {
  const DeckInfo({super.key});

  @override
  DeckInfoState createState() => DeckInfoState();
}

class DeckInfoState extends State<DeckInfo> {
  // Stores the current number of cards in the deck
  String deckCount = "41/52";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Updates the deck count when tapped (example update)
        setState(() {
          deckCount = "40/52";
        });
      },
      child: SizedBox(
        width: 60, // Width of the container
        height: 85, // Height of the container
        child: Stack(
          children: [
            // Bottom layer of the card stack
            Positioned(top: 10, left: 5, child: _buildCard()),

            // Middle layer of the card stack
            Positioned(top: 5, left: 10, child: _buildCard()),

            // Top layer of the card stack
            Positioned(top: 0, left: 15, child: _buildCard()),

            // Displays the number of remaining cards
            Positioned(
              bottom: -5,
              left: 15,
              child: Text(
                deckCount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single card with a white background and a black border.
  Widget _buildCard() {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black, width: 2),
      ),
    );
  }
}
