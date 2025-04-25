import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/action_buttons_widget.dart';
import 'package:nogler/widgets/in_game/card_widget.dart';
import 'package:nogler/widgets/in_game/deck_info_widget.dart';
import 'package:nogler/widgets/in_game/game_fase/selected_cards_widget.dart';
import 'package:nogler/widgets/in_game/main_cards_widget.dart';

class GameFaseWidget extends StatelessWidget {
  const GameFaseWidget({
    super.key,
    required this.mainCardsKey,
    required this.selectedCardsKey,
    required this.remainingCards,
    required this.onDeckUpdated,
    required this.onPlayCards,
    required this.onDiscardUpdated,
    required this.onPlayingUpdated,
    required this.onBlueScore,
    required this.onRedScore,
    required this.onScore,
    required this.onHandType,
    required this.currentDeckSize,
    required this.blind,
    required this.handCards,
  });

  final GlobalKey<MainCardsState> mainCardsKey;
  final GlobalKey<SelectedCardsState> selectedCardsKey;
  final int remainingCards;
  final Function(int) onDeckUpdated;
  final Function(List<SelectableCard>) onPlayCards;
  final Function(int) onDiscardUpdated;
  final Function(int) onPlayingUpdated;
  final Function(int)? onScore;
  final Function(int)? onBlueScore;
  final Function(int)? onRedScore;
  final Function(int)? onHandType;
  final int currentDeckSize;
  final int blind;
  final List<SelectableCard> handCards;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 5),

        SelectedCards(
          key: selectedCardsKey,
          onBlueScore: onBlueScore,
        ), // Widget displaying selected cards

        const SizedBox(height: 5),

        MainCards(
          key: mainCardsKey,
          onDeckUpdated: onDeckUpdated,
          // Callback function
          onPlayCards: onPlayCards,
          onDiscardUpdated: onDiscardUpdated,
          onPlayingdUpdated: onPlayingUpdated,
          onBlueScore: onBlueScore,
          onRedScore: onRedScore,
          onScore: onScore,
          onHandType: onHandType,
          blind: blind,
          handCards: handCards,
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
              mainCardsKey: mainCardsKey,
            ),
            SizedBox(width: 15),
            DeckInfo(
              remainingCards: remainingCards,
              currentDeckSize: currentDeckSize,
            ),
          ],
        ),
      ],
    );
  }
}
