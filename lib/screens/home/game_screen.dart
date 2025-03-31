import 'package:flutter/material.dart';
import 'package:nogler/widgets/action_buttons_widget.dart';
import 'package:nogler/widgets/background_widget.dart';
import 'package:nogler/widgets/deck_info_widget.dart';
import 'package:nogler/widgets/joker_cards_widget.dart';
import 'package:nogler/widgets/main_cards_widget.dart';
import 'package:nogler/widgets/selected_cards_widget.dart';
import 'package:nogler/widgets/setting_button_widget.dart';
import 'package:nogler/widgets/sidebar_widget.dart';
import 'package:nogler/widgets/timer_widget.dart';

/// Represents the main game screen with UI components for gameplay.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  final GlobalKey<MainCardsState> _mainCardsKey = GlobalKey();
  int _remainingCards = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Stack(
            children: [
              // Main row containing the Sidebar and game UI elements
              Row(
                children: [
                  Sidebar(), // Sidebar for navigation and game info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        // Section for the Joker cards at the top left
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .start, // Aligns JokerCards to the left
                            children: [JokerCards()],
                          ),
                        ),

                        SelectedCards(), // Widget displaying selected cards
                        SizedBox(height: 15),

                        // MainCards widget in the center
                        MainCards(
                          key: _mainCardsKey,
                          onDeckUpdated: (value) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                _remainingCards = value;
                              });
                            });
                          },
                        ),

                        SizedBox(height: 5),

                        // Action buttons and deck info at the bottom
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 75),
                            ActionButtons(
                              onDiscard: () {
                                _mainCardsKey.currentState
                                    ?.discardSelectedCards();
                              },
                            ),
                            SizedBox(width: 15),
                            DeckInfo(remainingCards: _remainingCards),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Timer and settings button placed at the top right
              TimerWidget(),
              SettingsButton(),
            ],
          ),
        ),
      ),
    );
  }
}
