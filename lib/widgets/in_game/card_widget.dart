import 'package:flutter/material.dart';
import 'package:nogler/classes/card_class.dart';
import 'package:playing_cards/playing_cards.dart';

/// Builds a visual playing card using the playing_cards package.
Widget buildCard(SelectableCard selectable) {
  return Stack(
    children: [
      PlayingCardView(card: selectable.card, showBack: false),
      // Overlay of the card
      if (cardOverlay[selectable.overlay]['overlay']! != "no overlay")
        Positioned.fill(
          // Needed to resize the card effects
          left: 4,
          right: 4,
          top: 4,
          bottom: 4,
          child: Opacity(
            opacity: 0.8,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              child: Image.asset(
                cardOverlay[selectable.overlay]['overlay']!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
    ],
  );
}
