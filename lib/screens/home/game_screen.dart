import 'package:flutter/material.dart';
import 'package:nogler/widgets/background_widget.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/game_fase/game_fase_widget.dart';
import 'package:nogler/widgets/in_game/game_fase/selected_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_cards_widget.dart';
import 'package:nogler/widgets/in_game/main_cards_widget.dart';
import 'package:nogler/widgets/in_game/setting_button_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_fase_widget.dart';
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
  // WebSocket
  //final WebSocketClient wsClient = WebSocketClient();

  List<Map<String, dynamic>> chatMessages = [];

  final GlobalKey<MainCardsState> _mainCardsKey = GlobalKey();
  final GlobalKey<SelectedCardsState> _selectedCardsKey = GlobalKey();
  final GlobalKey<JokerCardsState> _jokerCardsKey =
      GlobalKey<JokerCardsState>();
  final GlobalKey<ConsumableCardsState> _consumableCardsKey =
      GlobalKey<ConsumableCardsState>();
  final GlobalKey<ShopWidgetState> _shopWidgetKey =
      GlobalKey<ShopWidgetState>();
  final GlobalKey<BuyWidgetState> _buyWidgetKey = GlobalKey<BuyWidgetState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Variables to animate the exit of the elements off screen
  bool _animateShowGameFaseWidgets = true;
  bool _animateShowShopFaseWidgets = false;

  // Show game fase widgets visibly
  bool _showGameFaseWidget = true;
  bool _showShopFaseWidget = false;

  int _remainingCards = 0;
  int animationTime = 500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dont redimension page if keyboard on
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,

      /*
      endDrawer: ChatWidget(
            myUsername: widget.hostName,
            myAvatarImage: widget.hostAvatar,
            lobbyCode: widget.lobbyCode,
            chatMessages: chatMessages,
          ),
          */
      body: BackgroundWidget(
        child: SafeArea(
          child: Stack(
            children: [
              // Main row containing the Sidebar and game UI elements
              Row(
                children: [
                  Sidebar(
                    consumableCardsKey: _consumableCardsKey,
                    shopWidgetKey: _shopWidgetKey,
                    buyWidgetKey: _buyWidgetKey,
                  ), // Sidebar for navigation and game info

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
                            children: [
                              JokerCards(
                                key: _jokerCardsKey,
                                shopWidgetKey: _shopWidgetKey,
                                buyWidgetKey: _buyWidgetKey,
                              ),
                            ],
                          ),
                        ),

                        if (_showGameFaseWidget)
                          // Widget with all game fase widgets included
                          // Show the widget if we're in game fase
                          Visibility(
                            visible: _showGameFaseWidget,
                            // Animate its entry and exit off screen
                            child: AnimatedSlide(
                              offset:
                                  _animateShowGameFaseWidgets
                                      ? Offset(0, 0)
                                      : Offset(0, 1),
                              duration: Duration(milliseconds: animationTime),
                              curve: Curves.easeInOut,

                              child: GameFaseWidget(
                                mainCardsKey: _mainCardsKey,
                                selectedCardsKey: _selectedCardsKey,
                                remainingCards: _remainingCards,
                                onDeckUpdated: (value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _remainingCards = value;
                                    });
                                  });
                                },
                                onPlayCards: (playedCards) {
                                  _selectedCardsKey.currentState?.showCards(
                                    playedCards,
                                  );
                                },
                              ),
                            ),
                          )
                        else if (_showShopFaseWidget)
                          Visibility(
                            visible: _showShopFaseWidget,
                            child: AnimatedSlide(
                              offset:
                                  _animateShowShopFaseWidgets
                                      ? Offset(0, 0)
                                      : Offset(0, 1),
                              duration: Duration(milliseconds: animationTime),
                              curve: Curves.easeInOut,

                              child: ShopFaseWidget(
                                shopWidgetKey: _shopWidgetKey,
                                buyWidgetKey: _buyWidgetKey,
                                jokerCardsKey: _jokerCardsKey,
                                consumableCardsKey: _consumableCardsKey,
                              ),
                            ),
                          ),
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
                    Future.delayed(Duration(milliseconds: animationTime), () {
                      setState(() {
                        // Change visible state of widgets
                        _showGameFaseWidget = !_showGameFaseWidget;
                        _animateShowShopFaseWidgets =
                            !_animateShowShopFaseWidgets;
                      });
                      Future.delayed(Duration(milliseconds: 1), () {
                        setState(() {
                          _showShopFaseWidget = !_showShopFaseWidget;
                        });
                      });
                    });
                  } else if (_animateShowShopFaseWidgets) {
                    setState(() {
                      // Init animation shop fase
                      _animateShowShopFaseWidgets = !_showShopFaseWidget;
                    });
                    Future.delayed(Duration(milliseconds: animationTime), () {
                      setState(() {
                        // Change visible state of widgets
                        _showShopFaseWidget = !_showShopFaseWidget;
                        // Init animation of game fase
                        _animateShowGameFaseWidgets =
                            !_animateShowGameFaseWidgets;
                      });
                      Future.delayed(Duration(milliseconds: 1), () {
                        setState(() {
                          _showGameFaseWidget = !_showGameFaseWidget;
                        });
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
