import 'package:flutter/material.dart';

/// A widget that displays a row of Joker cards.
/// The number of cards is generated dynamically and displayed below.
class JokerCards extends StatefulWidget {
  const JokerCards({super.key});

  @override
  JokerCardsState createState() => JokerCardsState();
}

class JokerCardsState extends State<JokerCards> {
  // List of Joker cards to be displayed
  final List<String> cards = List.generate(5, (index) => 'Joker');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Displays the row of Joker cards.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cards.map((card) => _buildCard(card, Colors.red)).toList(),
        ),
        

        // Displays the count of Joker cards.
        Text(
          "${cards.length} / 5",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Builds a single Joker card widget.
  Widget _buildCard(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        width: 50,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
