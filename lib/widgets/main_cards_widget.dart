import 'package:flutter/material.dart';

/// A widget that displays a set of main cards.
/// The number of cards is dynamically generated and arranged in a flexible layout.
class MainCards extends StatefulWidget {
  const MainCards({super.key});

  @override
  MainCardsState createState() => MainCardsState();
}

class MainCardsState extends State<MainCards> {
  // List of main hand cards to be displayed
  final List<String> handCards = List.generate(8, (index) => 'Card');

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10, // Horizontal spacing between cards
      runSpacing: 10, // Vertical spacing between rows of cards
      alignment: WrapAlignment.center, // Center align the cards
      children:
          handCards.map((card) => _buildCard(card, Colors.white)).toList(),
    );
  }

  /// Builds a single card widget.
  Widget _buildCard(String label, Color color) {
    return Container(
      width: 60,
      height: 90,
      color: color,
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
