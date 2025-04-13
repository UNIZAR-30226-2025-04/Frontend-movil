import 'package:flutter/material.dart';

/// A widget that displays deck information with a stack of cards and the card count.
/// The count updates when the widget is tapped.
class DeckInfo extends StatelessWidget {
  final int remainingCards;

  const DeckInfo({super.key, required this.remainingCards});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      child: SizedBox(
        width: 60, // Width of the container
        height: 70, // Height of the container
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
              left: 10,
              child: Text(
                "$remainingCards / 52",
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
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white, width: 2),
        image: DecorationImage(
        image: AssetImage('images/Blue_Deck.png'), // Ruta de tu imagen
        fit: BoxFit.cover, // Ajuste de la imagen
      ),
      ),
    );
  }
}
