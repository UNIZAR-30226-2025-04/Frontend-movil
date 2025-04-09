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

  SelectableCard({
    required this.rank,
    required this.suit,
    required this.overlay,
    required this.card,
    this.isSelected = false,
    this.isDiscarding = false,
    this.isNew = false,
  });
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
    'overlay': 'images/glassDemo3.png',
    'overlayName': 'Glass card',
    'overlayDescription': '2x each played glass card',
  },
];
