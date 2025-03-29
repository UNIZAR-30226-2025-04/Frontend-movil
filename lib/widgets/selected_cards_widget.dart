import 'package:flutter/material.dart';

/// A widget that displays a row of selected cards.
/// The number of cards is generated dynamically.
class SelectedCards extends StatefulWidget {
  const SelectedCards({super.key});

  @override
  SelectedCardsState createState() => SelectedCardsState();
}

class SelectedCardsState extends State<SelectedCards> {
  // List of selected cards to be displayed
  final List<String> cards = List.generate(5, (index) => 'Card');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          cards
              .map(
                (card) =>
                    _buildCard(card, const Color.fromARGB(255, 54, 244, 149)),
              )
              .toList(),
    );
  }

  /// Builds a single selected card widget
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
