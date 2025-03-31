import 'dart:math';

import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

/// A widget that displays a set of main cards with draggable behavior.
class MainCards extends StatefulWidget {
  const MainCards({super.key});

  @override
  MainCardsState createState() => MainCardsState();
}

class MainCardsState extends State<MainCards> {
  /// List of playing cards to be displayed
  List<PlayingCard> handCards = [];

  /// Stores the index of the dragged card
  int? _draggedIndex;

  @override
  void initState() {
    super.initState();
    _generateRandomHand();
  }

  void _generateRandomHand() {
    final random = Random();
    final fullDeck = <PlayingCard>[];

    for (var suit in Suit.values) {
      for (var value in CardValue.values) {
        fullDeck.add(PlayingCard(suit, value));
      }
    }

    fullDeck.shuffle(random);
    handCards = fullDeck.take(8).toList(); // toma 8 cartas aleatorias
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(handCards.length, (index) {
        return _buildDraggableCard(index);
      }),
    );
  }

  /// Builds a draggable and droppable card.
  Widget _buildDraggableCard(int index) {
    final card = handCards[index];

    return DragTarget<int>(
      onAcceptWithDetails: (details) {
        final fromIndex = details.data;
        setState(() {
          final temp = handCards[fromIndex];
          handCards[fromIndex] = handCards[index];
          handCards[index] = temp;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Draggable<int>(
          data: index,
          onDragStarted: () {
            setState(() {
              _draggedIndex = index;
            });
          },
          onDragEnd: (_) {
            setState(() {
              _draggedIndex = null;
            });
          },
          feedback: Container(
            width: 65,
            height: 97,
            color: Colors.transparent,
            child: _buildCard(card),
          ),
          childWhenDragging:
              _draggedIndex == index
                  ? const SizedBox.shrink()
                  : _buildCard(card),
          child: _buildCard(card),
        );
      },
    );
  }

  /// Builds a visual playing card using the playing_cards package.
  Widget _buildCard(PlayingCard card) {
    return Container(
      width: 65,
      height: 97,
      decoration: BoxDecoration(color: Colors.transparent),
      child: PlayingCardView(card: card, showBack: false),
    );
  }
}
