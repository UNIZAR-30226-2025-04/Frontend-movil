import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

/// A widget that displays a row of played cards temporarily.
class SelectedCards extends StatefulWidget {
  const SelectedCards({super.key});

  @override
  SelectedCardsState createState() => SelectedCardsState();
}

class SelectedCardsState extends State<SelectedCards> {
  // Lista de cartas reales
  List<PlayingCard> cards = [];

  /// Show cards temporarily when a hand is played
  void showCards(List<PlayingCard> newCards) {
    setState(() {
      cards = newCards;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const SizedBox(height: 97); // Espacio reservado para las cartas
    }

    return SizedBox(
      height: 97,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: cards.map(_buildCard).toList(),
      ),
    );
  }

  Widget _buildCard(PlayingCard card) {
    return AspectRatio(
      aspectRatio: 65 / 90,
      child: PlayingCardView(card: card, showBack: false),
    );
  }
}
