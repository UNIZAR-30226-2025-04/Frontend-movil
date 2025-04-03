import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

/// A widget that displays a row of played cards temporarily.
class SelectedCards extends StatefulWidget {
  const SelectedCards({super.key});

  @override
  SelectedCardsState createState() => SelectedCardsState();
}

class SelectedCardsState extends State<SelectedCards> {
  // / List of cards to be displayed temporarily
  List<PlayingCard> cards = [];
  Set<int> bouncingIndices = {};
  Set<int> scoringIndices = {};
  Set<int> appearingIndices = {};

  /// Show cards temporarily when a hand is played
  Future<void> showCards(List<PlayingCard> newCards) async {
    setState(() {
      cards = newCards;
      bouncingIndices.clear();
      scoringIndices.clear();
      appearingIndices.clear();
    });
    // Show the cards one by one with a delay
    for (int i = 0; i < newCards.length; i++) {
      await Future.delayed(Duration(milliseconds: 200));
      setState(() {
        appearingIndices.add(i);
      });
    }

    // After all cards are shown, animate them with a bounce effect
    for (int i = 0; i < newCards.length; i++) {
      await Future.delayed(Duration(milliseconds: 200));
      if (!mounted) return;

      setState(() {
        bouncingIndices.add(i);
        scoringIndices.add(i);
      });

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      setState(() {
        bouncingIndices.remove(i);
        scoringIndices.remove(i);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const SizedBox(height: 90);
    }

    return SizedBox(
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(cards.length, (i) => _buildCard(cards[i], i)),
      ),
    );
  }

  Widget _buildCard(PlayingCard card, int index) {
    // Check if the card is in the bouncing, scoring or appearing state
    final isAppearing = appearingIndices.contains(index);
    final isBouncing = bouncingIndices.contains(index);
    final isScoring = scoringIndices.contains(index);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isAppearing ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: isAppearing ? Offset.zero : const Offset(0, 0.3),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedSlide(
              offset: isBouncing ? const Offset(0, -0.2) : Offset.zero,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: AnimatedScale(
                scale: isBouncing ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AspectRatio(
                  aspectRatio: 65 / 90,
                  child: PlayingCardView(card: card, showBack: false),
                ),
              ),
            ),
            if (isScoring)
              Positioned(
                top: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: -10.0, end: -30.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: 1 - (value + 30) / 20,
                      child: Transform.translate(
                        offset: Offset(0, value),
                        child: child,
                      ),
                    );
                  },
                  child: const Text(
                    '+10',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
