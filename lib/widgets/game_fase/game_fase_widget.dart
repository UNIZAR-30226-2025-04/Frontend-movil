import 'package:flutter/material.dart';
import 'package:nogler/widgets/action_buttons_widget.dart';
import 'package:nogler/widgets/deck_info_widget.dart';
import 'package:nogler/widgets/main_cards_widget.dart';
import 'package:nogler/widgets/selected_cards_widget.dart';
import 'package:playing_cards/playing_cards.dart';

class GameFaseWidget extends StatelessWidget {
  const GameFaseWidget({
    super.key,
    required this.mainCardsKey,
    required this.selectedCardsKey,
    required this.remainingCards,
    required this.onDeckUpdated,
    required this.onPlayCards,
  });

  final GlobalKey<MainCardsState> mainCardsKey;
  final GlobalKey<SelectedCardsState> selectedCardsKey;
  final int remainingCards;
  final Function(int) onDeckUpdated;
  final Function(List<PlayingCard>) onPlayCards;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 5),

        SelectedCards(
          key: selectedCardsKey,
        ), // Widget displaying selected cards

        const SizedBox(height: 5),

        MainCards(
          key: mainCardsKey,
          onDeckUpdated: onDeckUpdated,
          // Callback function
          onPlayCards: onPlayCards,
        ),

        // Action buttons and deck info at the bottom
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 75),
            ActionButtons(
              onDiscard: () {
                mainCardsKey.currentState?.discardSelectedCards();
              },
              onPlayHand: () {
                mainCardsKey.currentState?.playSelectedCards();
              },
            ),
            SizedBox(width: 15),
            DeckInfo(remainingCards: remainingCards),
          ],
        ),
      ],
    );
  }
}
