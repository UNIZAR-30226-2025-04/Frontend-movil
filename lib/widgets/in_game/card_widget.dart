import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

/// Poker card class
class SelectableCard {
  final String rank;
  final String suit;
  final int overlay;
  final PlayingCard card;
  bool isSelected;
  bool isDiscarding;
  bool isNew;
  bool isScored;
  String score;
  String blueScore;

  SelectableCard({
    required this.rank,
    required this.suit,
    required this.overlay,
    required this.card,
    this.isSelected = false,
    this.isDiscarding = false,
    this.isNew = false,
    this.isScored = false,
    this.score = '',
    this.blueScore = '',
  });
}

/// Builds a visual playing card using the playing_cards package.
Widget buildCard(SelectableCard selectable) {
  return Stack(
    children: [
      // Shadow effect
      Container(
        height: 82,
        width: 53,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: Offset(9, 9), // Position of the shadow
              blurRadius: 7, // Blur of the image
              spreadRadius: 1, // Size of the shadow
            ),
          ],
        ),
      ),
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
              borderRadius: BorderRadius.all(Radius.circular(12)),
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

/// Overlay list map to extract:
/// - overlay rute to image
/// - overlay name
/// - overlay description: the effect of the overlay
List<Map<String, String>> cardOverlay = [
  {
    // No overlay
    'overlay': 'no overlay',
    'overlayName': '',
    'overlayDescription': '',
  },
  {
    // Glass overlay
    'overlay': 'images/cards_overlay/glassDemo3.png',
    'overlayName': 'Glass card',
    'overlayDescription': 'x2 each played glass card',
  },
  {
    // No overlay
    'overlay': 'images/cards_overlay/glassDemo3.png',
    'overlayName': '',
    'overlayDescription': '',
  },
];
