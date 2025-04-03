import 'package:flutter/material.dart';
import 'package:nogler/widgets/background_widget.dart';
import 'package:nogler/widgets/in_game/game_fase/game_fase_widget.dart';
import 'package:nogler/widgets/in_game/game_fase/selected_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_cards_widget.dart';
import 'package:nogler/widgets/in_game/main_cards_widget.dart';
import 'package:nogler/widgets/in_game/setting_button_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';
import 'package:nogler/widgets/in_game/sidebar_widget.dart';
import 'package:nogler/widgets/in_game/timer_widget.dart';

/// Represents the main game screen with UI components for gameplay.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  final GlobalKey<MainCardsState> _mainCardsKey = GlobalKey();
  final GlobalKey<SelectedCardsState> _selectedCardsKey = GlobalKey();

  // Variables to animate the exit of the elements off screen
  bool _animateShowGameFaseWidgets = true;
  bool _animateShowShopFaseWidgets = false;

  // Show game fase widgets visibly
  bool _showGameFaseWidget = true;
  bool _showShopFaseWidget = false;

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

                        if (_showGameFaseWidget)
                          Expanded(
                            // Widget with all game fase widgets included
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Show the widget if we're in game fase
                                Visibility(
                                  visible: _showGameFaseWidget,
                                  // Animate its entry and exit off screen
                                  child: AnimatedSlide(
                                    offset:
                                        _animateShowGameFaseWidgets
                                            ? Offset(0, 0)
                                            : Offset(0, 3),
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,

                                    child: GameFaseWidget(
                                      mainCardsKey: _mainCardsKey,
                                      selectedCardsKey: _selectedCardsKey,
                                      remainingCards: _remainingCards,
                                      onDeckUpdated: (value) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              setState(() {
                                                _remainingCards = value;
                                              });
                                            });
                                      },
                                      onPlayCards: (playedCards) {
                                        _selectedCardsKey.currentState
                                            ?.showCards(playedCards);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_showShopFaseWidget)
                          Expanded(child: Column(children: [Shop()])),
                      ],
                    ),
                  ),
                ],
              ),

              // Timer and settings button placed at the top right
              TimerWidget(),
              SettingsButton(
                //TODO, puesto para cambiar entre fase de juego y tienda, cambiar a posteriori
                onPressed: () {
                  // Animate Game Fase Widgets
                  if (_animateShowGameFaseWidgets) {
                    setState(() {
                      // Init animation game fase
                      _animateShowGameFaseWidgets =
                          !_animateShowGameFaseWidgets;
                    });
                    Future.delayed(Duration(milliseconds: 300), () {
                      setState(() {
                        // Change visible state of widgets
                        _showGameFaseWidget = !_showGameFaseWidget;
                        _showShopFaseWidget = !_showShopFaseWidget;
                        _animateShowShopFaseWidgets =
                            !_animateShowShopFaseWidgets;
                      });
                    });
                  } else if (_animateShowShopFaseWidgets) {
                    setState(() {
                      // Init animation shop fase
                      _animateShowShopFaseWidgets = !_showShopFaseWidget;
                    });
                    Future.delayed(Duration(milliseconds: 300), () {
                      setState(() {
                        // Change visible state of widgets
                        _showShopFaseWidget = !_showShopFaseWidget;
                        _showGameFaseWidget = !_showGameFaseWidget;
                        // Init animation of game fase
                        _animateShowGameFaseWidgets =
                            !_animateShowGameFaseWidgets;
                      });
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
