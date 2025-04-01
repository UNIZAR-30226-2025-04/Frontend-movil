import 'dart:math';
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

/// A widget that displays a set of main cards with draggable behavior.
class MainCards extends StatefulWidget {
  final Function(int)? onDeckUpdated;
  final void Function(List<PlayingCard>)? onPlayCards;
  const MainCards({super.key, this.onDeckUpdated, this.onPlayCards});

  @override
  MainCardsState createState() => MainCardsState();
}

class SelectableCard {
  final String rank;
  final String suit;
  final PlayingCard card;
  bool isSelected;
  bool isDiscarding;
  bool isNew;

  SelectableCard({
    required this.rank,
    required this.suit,
    required this.card,
    this.isSelected = false,
    this.isDiscarding = false,
    this.isNew = false,
  });
}

class MainCardsState extends State<MainCards> {
  List<SelectableCard> handCards = [];
  List<PlayingCard> remainingDeck = [];

  /// Stores the index of the dragged card
  int? _draggedIndex;
  int get remainingCards => remainingDeck.length;
  bool hasMountedInitialHand = false;

  @override
  void initState() {
    super.initState();
    _generateRandomHand();
  }

  void _generateRandomHand() {
    final random = Random();
    final fullDeck = <PlayingCard>[];

    for (var suit in Suit.values) {
      if (suit == Suit.joker) continue; // Avoid adding jokers to the deck
      for (var value in CardValue.values) {
        if (value != CardValue.joker_1 && value != CardValue.joker_2) {
          fullDeck.add(PlayingCard(suit, value));
        }
      }
    }

    fullDeck.shuffle(random);
    remainingDeck = fullDeck; // All the cards in the deck

    // Steal 8 cards from the deck
    handCards = List.generate(8, (_) {
      final card = remainingDeck.removeAt(0);
      return SelectableCard(
        rank: card.value.toString().split('.').last,
        suit: card.suit.toString().split('.').last,
        card: card,
      );
    });

    // Notify the parent widget about the initial deck size
    widget.onDeckUpdated?.call(remainingDeck.length);
    setState(() {
      hasMountedInitialHand = true;
    });
  }

  /// Discards selected cards and replaces them with new ones from the deck.
  void discardSelectedCards() async {
    final selected = handCards.where((c) => c.isSelected).toList();
    // Notify the parent widget about the discarded cards
    setState(() {
      for (var c in selected) {
        c.isDiscarding = true;
      }
    });

    // Simulate a delay for the animation effect
    await Future.delayed(const Duration(milliseconds: 350));

    // Notify the parent widget about the discarded cards
    setState(() {
      handCards.removeWhere((c) => c.isDiscarding);
    });
    await Future.delayed(const Duration(milliseconds: 300));

    for (var i = 0; i < selected.length; i++) {
      if (remainingDeck.isNotEmpty) {
        final newCard = remainingDeck.removeAt(0);
        final selectable = SelectableCard(
          rank: newCard.value.toString().split('.').last,
          suit: newCard.suit.toString().split('.').last,
          card: newCard,
          isNew: true,
        );
        setState(() {
          handCards.add(selectable);
        });
        await Future.delayed(const Duration(milliseconds: 200));

        setState(() {
          selectable.isNew = false;
        });
        // Simulate a delay for the animation effect
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    // Notify the parent widget about the updated deck size
    widget.onDeckUpdated?.call(remainingDeck.length);
  }

  /// Plays selected cards and replaces them with new ones from the deck.
  void playSelectedCards() async {
    final selected = handCards.where((c) => c.isSelected).toList();
    final selectedCards = selected.map((c) => c.card).toList();
    final time = selectedCards.length + 1;

    // Notify the parent widget about the played cards
    widget.onPlayCards?.call(selectedCards);
    // Notify the parent widget about the discarded cards
    setState(() {
      for (var c in selected) {
        c.isDiscarding = true;
      }
    });

    // Simulate a delay for the animation effect
    await Future.delayed(const Duration(milliseconds: 350));

    // Notify the parent widget about the discarded cards
    setState(() {
      handCards.removeWhere((c) => c.isDiscarding);
    });

    // Simulate a delay for the animation effect
    await Future.delayed(Duration(seconds: time));

    // Clear the played cards from the parent widget
    widget.onPlayCards?.call([]);

    // Add new cards to the hand
    for (var i = 0; i < selected.length; i++) {
      if (remainingDeck.isNotEmpty) {
        final newCard = remainingDeck.removeAt(0);
        final selectable = SelectableCard(
          rank: newCard.value.toString().split('.').last,
          suit: newCard.suit.toString().split('.').last,
          card: newCard,
          isNew: true,
        );

        // Notify the parent widget about the new card
        setState(() {
          handCards.add(selectable);
        });

        // Simulate a delay for the animation effect
        await Future.delayed(const Duration(milliseconds: 200));

        // This will trigger the animation to show the card
        setState(() {
          selectable.isNew = false;
        });
        // Simulate a delay for the animation effect
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    // Notify the parent widget about the updated deck size
    widget.onDeckUpdated?.call(remainingDeck.length);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child:
          hasMountedInitialHand
              ? Row(
                key: ValueKey(
                  handCards.map((c) => '${c.rank}_${c.suit}').join(),
                ),
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(handCards.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 65,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: _buildDraggableCard(index),
                  );
                }),
              )
              : Row(
                // Versión sin key para que no haga animaciones en el primer render
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(handCards.length, (index) {
                  return SizedBox(width: 65, child: _buildDraggableCard(index));
                }),
              ),
    );
  }

  /// Builds a draggable and droppable card.
  Widget _buildDraggableCard(int index) {
    final card = handCards[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          final selectedCount = handCards.where((c) => c.isSelected).length;
          final isSelected = handCards[index].isSelected;

          if (isSelected || selectedCount < 5) {
            handCards[index].isSelected = !isSelected;
          }
        });
      },
      child: DragTarget<int>(
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
      ),
    );
  }

  /// Builds a visual playing card using the playing_cards package.
  Widget _buildCard(SelectableCard selectable) {
    return AspectRatio(
      aspectRatio: 65 / 90,
      child: AnimatedOpacity(
        opacity: selectable.isDiscarding ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: AnimatedSlide(
          offset:
              selectable.isDiscarding
                  ? const Offset(0, 0.5)
                  : selectable.isNew
                  ? const Offset(0, 0.5)
                  : (selectable.isSelected
                      ? const Offset(0, -0.1)
                      : Offset.zero),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: selectable.isNew ? 0.8 : 1.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: PlayingCardView(card: selectable.card, showBack: false),
          ),
        ),
      ),
    );
  }
}
