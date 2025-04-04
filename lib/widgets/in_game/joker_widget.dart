import 'package:flutter/material.dart';

class Joker extends StatelessWidget {
  const Joker({super.key});

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: 'joker_card', // Data of the card
      feedback: _buildJokerCard(), // Shown when dragging
      childWhenDragging: Opacity(opacity: 0, child: _buildJokerCard()),
      child: _buildJokerCard(),
    );
  }

  Widget _buildJokerCard({double height = 80}) {
    return Container(
      width: 60,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      //TODO, Add images of jokers next
      child: Text(
        "Joker",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
