import 'package:flutter/material.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/chat_widget.dart';
import 'package:nogler/widgets/game_background_widget.dart';
import 'package:nogler/widgets/in_game/choose_blind_fase/choose_blind_fase_widget.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/consumable_fase/consumable_fase_widget.dart';
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
    required this.timeout,
  });
  final int round;
  final String hostName;
  final int hostAvatar;
  final String lobbyCode;
  final int timeout;
  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  // WebSocket
  final WebSocketClient wsClient = WebSocketClient();
  List<Map<String, dynamic>> chatMessages = [];
  List<Map<String, dynamic>> lobbyUsers = [];

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
  final GlobalKey<ConsumableFaseWidgetState> _consumableFaseWidgetKey =
      GlobalKey<ConsumableFaseWidgetState>();

  // Variables to animate the exit of the elements off screen
  bool _animateShowChooseBlindFaseWidget = true;
  bool _animateShowGameFaseWidgets = false;
  bool _animateShowShopFaseWidgets = false;
  bool _animateShowConsumableFaseWidget = false;

  // Show fase widgets visibly
  bool _showChooseBlindFaseWidget = true;
  bool _showGameFaseWidget = false;
  bool _showShopFaseWidget = false;
  bool _showConsumableFaseWidget = false;

  String _currentFase = "chooseBlindFase";

  int _remainingCards = 0;
  int _discardingCards = 3;
  int _playingCards = 3;
  int animationTime = 500;
  late int _timeout;
  int _blueScore = 0;
  int _redScore = 0;
  int _score = 0;
  int _handType = 1;
  int _currentDeckSize = 0;
  int _gold = 400;
  @override
  void initState() {
    super.initState();
    _timeout = widget.timeout;
    wsClient.removeEventListener("new_lobby_message");
    wsClient.removeEventListener("lobby_info");
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

      // Listen for lobby info
      wsClient.addEventListener("lobby_info", (data) {
        debugPrint("📡 Received lobby info: $data");

        final players = data['players'] as List<dynamic>;
        setState(() {
          lobbyUsers =
              players.map<Map<String, dynamic>>((player) {
                return {
                  'username': player['username'] ?? 'Unknown',
                  'avatarImage': player['user_icon'] ?? 0,
                };
              }).toList();
        });
      });

      debugPrint("🟩 Total messages: ${chatMessages.length}");
    });

    // Listen for round start event
    wsClient.addEventListener("starting_round", (data) async {
      debugPrint("📡 Starting round: $data");
      final newTimeout = data['timeout'] as int;
      final deckSize = data['current_deck_size'] as int;
      setState(() {
        // Init game fase
        _showChooseBlindFaseWidget = !_showChooseBlindFaseWidget;
        _showGameFaseWidget = !_showGameFaseWidget;
        _animateShowGameFaseWidgets = !_animateShowGameFaseWidgets;
        _animateShowChooseBlindFaseWidget = !_animateShowChooseBlindFaseWidget;
        _currentFase = "gameFase";
        _timeout = newTimeout;
        _currentDeckSize = deckSize;
      });
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
                    consumableFaseWidgetKey: _consumableFaseWidgetKey,
                    sellWidgetKey: _sellWidgetKey,
                    round: widget.round,
                    discardingCards: _discardingCards,
                    playingCards: _playingCards,
                    currentFase: _currentFase,
                    isShopPhase: _showShopFaseWidget,
                    score: _score,
                    blueScore: _blueScore,
                    redScore: _redScore,
                    handType: _handType,
                    gold: _gold,
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

                        if (_showChooseBlindFaseWidget)
                          // Widget set to introduce the threshold to superpass in this round
                          // Show the widget if we're in choose blind fase
                          Visibility(
                            visible: _showChooseBlindFaseWidget,
                            // Animate its entry and exit off screen
                            child: AnimatedSlide(
                              offset:
                                  _animateShowChooseBlindFaseWidget
                                      ? Offset(0, 0)
                                      : Offset(0, 1),
                              duration: Duration(milliseconds: animationTime),
                              curve: Curves.easeInOut,
                              child: ChooseBlindFaseWidget(
                                lobbyCode: widget.lobbyCode,
                              ),
                            ),
                          )
                        else if (_showGameFaseWidget)
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
                                onScore: (value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _score = value;
                                    });
                                  });
                                },
                                onBlueScore: (value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _blueScore = value;
                                    });
                                  });
                                },
                                onRedScore: (value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _redScore = value;
                                    });
                                  });
                                },
                                onHandType: (value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _handType = value;
                                    });
                                  });
                                },
                                currentDeckSize: _currentDeckSize,
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
                                onBuy: (value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _gold -= value;
                                    });
                                  });
                                },
                                onSell: (value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _gold += value;
                                    });
                                  });
                                },
                              ),
                            ),
                          )
                        else if (_showConsumableFaseWidget)
                          Visibility(
                            visible: _showConsumableFaseWidget,
                            child: AnimatedSlide(
                              offset:
                                  _animateShowConsumableFaseWidget
                                      ? Offset(0, 0)
                                      : Offset(0, 1),
                              duration: Duration(milliseconds: animationTime),
                              curve: Curves.easeInOut,
                              child: ConsumableFaseWidget(
                                key: _consumableFaseWidgetKey,
                                consumableCardsKey: _consumableCardsKey,
                                lobbyUsers: lobbyUsers,
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
                    TimerWidget(timeout: _timeout),
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
                        // Animate Choose Blind Fase Widget
                        if (_animateShowChooseBlindFaseWidget) {
                          setState(() {
                            _animateShowChooseBlindFaseWidget =
                                !_animateShowChooseBlindFaseWidget;
                            _currentFase = "gameFase";
                          });
                          Future.delayed(
                            Duration(milliseconds: animationTime),
                            () {
                              setState(() {
                                // Change visible state of widgets
                                _showChooseBlindFaseWidget =
                                    !_showChooseBlindFaseWidget;
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
                        // Animate Game Fase Widgets
                        else if (_animateShowGameFaseWidgets) {
                          setState(() {
                            // Init animation game fase
                            _animateShowGameFaseWidgets =
                                !_animateShowGameFaseWidgets;
                            _currentFase = "shopFase";
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
                          // Animate Shop Fase Widgets
                        } else if (_animateShowShopFaseWidgets) {
                          setState(() {
                            // Init animation shop fase
                            _animateShowShopFaseWidgets =
                                !_animateShowShopFaseWidgets;
                            _currentFase = "consumableFase";
                          });
                          Future.delayed(
                            Duration(milliseconds: animationTime),
                            () {
                              setState(() {
                                // Change visible state of widgets
                                _showShopFaseWidget = !_showShopFaseWidget;
                                // Init animation of consumable fase
                                _animateShowConsumableFaseWidget =
                                    !_animateShowConsumableFaseWidget;
                              });
                              Future.delayed(Duration(milliseconds: 1), () {
                                setState(() {
                                  _showConsumableFaseWidget =
                                      !_showConsumableFaseWidget;
                                });
                              });
                            },
                          );
                        }
                        // Animate Consumable Fase Widgets
                        else if (_animateShowConsumableFaseWidget) {
                          setState(() {
                            // Init animation consumable fase
                            _animateShowConsumableFaseWidget =
                                !_animateShowConsumableFaseWidget;
                            _currentFase = "chooseBlindFase";
                          });
                          Future.delayed(
                            Duration(milliseconds: animationTime),
                            () {
                              setState(() {
                                // Change visible state of widgets
                                _showConsumableFaseWidget =
                                    !_showConsumableFaseWidget;
                                // Init animation of choose blind fase
                                _animateShowChooseBlindFaseWidget =
                                    !_animateShowChooseBlindFaseWidget;
                              });
                              Future.delayed(Duration(milliseconds: 1), () {
                                setState(() {
                                  _showChooseBlindFaseWidget =
                                      !_showChooseBlindFaseWidget;
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
