import 'package:flutter/material.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/chat_widget.dart';
import 'package:nogler/widgets/game_background_widget.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/game_fase/game_fase_widget.dart';
import 'package:nogler/widgets/in_game/game_fase/selected_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_cards_widget.dart';
import 'package:nogler/widgets/in_game/main_cards_widget.dart';
import 'package:nogler/widgets/in_game/setting_button_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/sell_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_fase_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';
import 'package:nogler/widgets/in_game/sidebar_widget.dart';
import 'package:nogler/widgets/in_game/timer_widget.dart';

/// Represents the main game screen with UI components for gameplay.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.round,
    required this.hostName,
    required this.hostAvatar,
    required this.lobbyCode,
  });
  final int round;
  final String hostName;
  final int hostAvatar;
  final String lobbyCode;
  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  // WebSocket
  final WebSocketClient wsClient = WebSocketClient();
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
  final GlobalKey<SellWidgetState> _sellWidgetKey =
      GlobalKey<SellWidgetState>();
  final GlobalKey<ShopFaseWidgetState> _shopFaseWidgetKey =
      GlobalKey<ShopFaseWidgetState>();

  // Variables to animate the exit of the elements off screen
  bool _animateShowGameFaseWidgets = true;
  bool _animateShowShopFaseWidgets = false;

  // Show game fase widgets visibly
  bool _showGameFaseWidget = true;
  bool _showShopFaseWidget = false;
  bool _isShopPhase = false;

  int _remainingCards = 0;
  int _discardingCards = 3;
  int _playingCards = 3;
  int animationTime = 500;

  @override
  void initState() {
    super.initState();
    wsClient.removeEventListener("new_lobby_message");
    // Listen for new lobby messages
    wsClient.addEventListener("new_lobby_message", (data) {
      debugPrint("🟨 Message received");
      setState(() {
        chatMessages.add({
          'username': data["username"] ?? "Unknown",
          'avatarImage': data["user_icon"] ?? 0,
          'message': data["message"] ?? "",
          'time': TimeOfDay.now().format(context),
        });
      });

      debugPrint("🟩 Total messages: ${chatMessages.length}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dont redimension page if keyboard on
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,

      endDrawer: ChatWidget(
        myUsername: widget.hostName,
        myAvatarImage: widget.hostAvatar,
        lobbyCode: widget.lobbyCode,
        chatMessages: chatMessages,
      ),
      body: GameBackgroundWidget(
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
                    shopFaseWidgetKey: _shopFaseWidgetKey,
                    sellWidgetKey: _sellWidgetKey,
                    round: widget.round,
                    discardingCards: _discardingCards,
                    playingCards: _playingCards,
                     isShopPhase: _isShopPhase,
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
                                shopFaseWidgetKey: _shopFaseWidgetKey,
                                sellWidgetKey: _sellWidgetKey,
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
                                onDiscardUpdated: (value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _discardingCards = value;
                                    });
                                  });
                                },
                                onPlayingUpdated: (value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _playingCards = value;
                                    });
                                  });
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
                                key: _shopFaseWidgetKey,
                                shopWidgetKey: _shopWidgetKey,
                                buyWidgetKey: _buyWidgetKey,
                                jokerCardsKey: _jokerCardsKey,
                                consumableCardsKey: _consumableCardsKey,
                                sellWidgetKey: _sellWidgetKey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              Positioned(
                top: 20,
                right: 20,
                child: Row(
                  children: [
                    TimerWidget(),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                      ),
                      onPressed: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                      child: const Icon(Icons.chat_bubble, color: Colors.black),
                    ),
                    const SizedBox(width: 8),

                    SettingsButton(
                      //TODO, puesto para cambiar entre fase de juego y tienda, cambiar a posteriori
                      onPressed: () {
                        // Animate Game Fase Widgets
                        if (_animateShowGameFaseWidgets) {
                          setState(() {
                            // Init animation game fase
                            _animateShowGameFaseWidgets =
                                !_animateShowGameFaseWidgets;
                                _isShopPhase = true; // Set to shop phase
                          });
                          Future.delayed(
                            Duration(milliseconds: animationTime),
                            () {
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
                            },
                          );
                        } else if (_animateShowShopFaseWidgets) {
                          setState(() {
                            // Init animation shop fase
                            _animateShowShopFaseWidgets = !_showShopFaseWidget;
                            _isShopPhase = false; // Set to game phase
                          });
                          Future.delayed(
                            Duration(milliseconds: animationTime),
                            () {
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
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
