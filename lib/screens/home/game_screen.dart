import 'package:flutter/material.dart';
import 'package:nogler/dialogs/game_dialogs.dart';
import 'package:nogler/screens/home/home_screen.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/chat_widget.dart';
import 'package:nogler/widgets/game_background_widget.dart';
import 'package:nogler/widgets/in_game/card_widget.dart';
import 'package:nogler/widgets/in_game/choose_blind_fase/choose_blind_fase_widget.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/consumable_fase/consumable_fase_widget.dart';
import 'package:nogler/widgets/in_game/consumable_fase/use_consumable_widget.dart';
import 'package:nogler/widgets/in_game/game_fase/game_fase_widget.dart';
import 'package:nogler/widgets/in_game/game_fase/selected_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/in_game/main_cards_widget.dart';
import 'package:nogler/widgets/in_game/setting_button_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/sell_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_fase_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';
import 'package:nogler/widgets/in_game/sidebar_widget.dart';
import 'package:nogler/widgets/in_game/timer_widget.dart';
import 'package:page_transition/page_transition.dart';

/// Represents the main game screen with UI components for gameplay.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.round,
    required this.hostName,
    required this.hostAvatar,
    required this.lobbyCode,
    required this.timeout,
    required this.phase,
    required this.baseBlind,
    required this.discardingCards,
    required this.playingCards,
    required this.handCards,
    required this.currentPoints,
    required this.currentDeckSize,
    required this.remainingCards,
    required this.jokersOwned,
    required this.shopJokers,
    required this.gold,
    required this.myBlind,
    required this.maxRounds,
    required this.consumablesOwned,
    required this.shopConsumables,
    required this.consumablesUsed,
  });
  final int round;
  final String hostName;
  final int hostAvatar;
  final String lobbyCode;
  final int timeout;
  final String phase;
  final int baseBlind;
  final int discardingCards;
  final int playingCards;
  final List<SelectableCard> handCards;
  final int currentPoints;
  final int currentDeckSize;
  final int remainingCards;
  final List<PurchasableItemInfo> jokersOwned;
  final List<PurchasableItemInfo> shopJokers;
  final int gold;
  final int myBlind;
  final int maxRounds;
  final List<PurchasableItemInfo> consumablesOwned;
  final List<PurchasableItemInfo> shopConsumables;
  final List<PurchasableItemInfo> consumablesUsed;

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
  final GlobalKey<OwnedConsumableCardsState> _ownedConsumableCardsKey =
      GlobalKey<OwnedConsumableCardsState>();
  final GlobalKey<UsedConsumableCardsState> _usedConsumableCardsKey =
      GlobalKey<UsedConsumableCardsState>();
  final GlobalKey<ShopWidgetState> _shopWidgetKey =
      GlobalKey<ShopWidgetState>();
  final GlobalKey<BuyWidgetState> _buyWidgetKey = GlobalKey<BuyWidgetState>();
  final GlobalKey<UseConsumableWidgetState> _useConsumableWidgetKey =
      GlobalKey<UseConsumableWidgetState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<SellWidgetState> _sellWidgetKey =
      GlobalKey<SellWidgetState>();
  final GlobalKey<ShopFaseWidgetState> _shopFaseWidgetKey =
      GlobalKey<ShopFaseWidgetState>();
  final GlobalKey<ConsumableFaseWidgetState> _consumableFaseWidgetKey =
      GlobalKey<ConsumableFaseWidgetState>();

  // Variables to animate the exit of the elements off screen
  bool _animateShowChooseBlindFaseWidget = false;
  bool _animateShowGameFaseWidgets = false;
  bool _animateShowShopFaseWidgets = false;
  bool _animateShowConsumableFaseWidget = false;

  // Show fase widgets visibly
  bool _showChooseBlindFaseWidget = false;
  bool _showGameFaseWidget = false;
  bool _showShopFaseWidget = false;
  bool _showConsumableFaseWidget = false;

  List<SelectableCard> _handCards = [];
  List<PurchasableItemInfo> _jokersOwned = [];

  String _currentFase = "";

  List<PurchasableItemInfo> consumablesOwned = [];
  List<PurchasableItemInfo> consumablesUsed = [];

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
  int _currentPot = 0;
  int _blind = 0;
  int _myBlind = 0;
  int _minBlind = 0;
  int _round = 0;
  int _maxRounds = 0;
  List<SelectableCard> _playedCards = [];
  List<PurchasableItemInfo> _shopJokers = [];
  List<PurchasableItemInfo> _shopConsumables = [];
  //List<PurchasableItemInfo> _shopPackages = [];
  @override
  void initState() {
    super.initState();
    consumablesOwned = widget.consumablesOwned;
    consumablesUsed = widget.consumablesUsed;
    _maxRounds = widget.maxRounds;
    _jokersOwned = widget.jokersOwned;
    _handCards = widget.handCards;
    _blind = widget.baseBlind;
    _minBlind = widget.baseBlind;
    _myBlind = widget.myBlind;
    _currentDeckSize = widget.currentDeckSize;
    _updatePhaseWidgets(widget.phase);
    _timeout = widget.timeout;
    _discardingCards = widget.discardingCards;
    _playingCards = widget.playingCards;
    _score = widget.currentPoints;
    _remainingCards = widget.remainingCards;
    _round = widget.round;
    _shopJokers = widget.shopJokers;
    _gold = widget.gold;
    wsClient.removeEventListener("new_lobby_message");
    wsClient.removeEventListener("lobby_info");
    wsClient.removeEventListener("starting_next_blind");
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
    // Listen for starting shop phase
    wsClient.addEventListener("starting_shop", (data) async {
      debugPrint("🏪 Received starting shop phase: $data");
      final time = _playedCards.where((card) => card.isScored).length + 1;
      await Future.delayed(Duration(seconds: time));

      final timeoutStart = DateTime.parse(data['timeout_start_date']).toLocal();
      final now = DateTime.now();
      final timeout = data['timeout'];
      debugPrint("timeoutStart: $timeoutStart, now: $now");
      debugPrint("Difference: ${timeoutStart.difference(now)}");
      // Calculate how many seconds are left from now until that date
      final timeUntilTimeout = timeout - now.difference(timeoutStart).inSeconds;
      setState(() {
        // Switch to the shop phase
        _animateShowShopFaseWidgets = true;
        _showShopFaseWidget = true;

        // Hide the game phase
        _animateShowGameFaseWidgets = false;
        _showGameFaseWidget = false;

        _currentFase = "shopFase";
        _timeout = timeUntilTimeout;
        _gold = data['money'];

        // Parse the shop items from the response
        _shopJokers = [];
        _shopConsumables = [];
        //_shopPackages = [];

        // Extracting jokers from the event data
        if (data['shop']['rerollable_items'] != null) {
          for (var joker in data['shop']['rerollable_items']) {
            _shopJokers.add(
              PurchasableItemInfo(
                price: joker['price'],
                id: joker['id'],
                index: 0,
                type: joker['type'],
                subtype: joker['joker_id'],
                cardName: '',
              ),
            );
          }
        }

        // Extracting packs from the event data
        /*if (data['shop']['fixed_packs'] != null) {
          for (var pack in data['shop']['fixed_packs']) {
            _shopPackages.add(
              PurchasableItemInfo(
                price: pack['price'],
                id: pack['id'],
                index: 0, // Assuming index is not available in the event data
                type: pack['type'],
                subtype:
                    0, // Assuming subtype is not available in the event data
                cardName:
                    "Pack ${pack['id']}", // Default naming, can be updated
              ),
            );
          }
        }*/

        // Extracting consumables from the event data if necessary
        // Assuming there are consumables in the event data (it wasn't in the sample response)
        if (data['shop']['fixed_modifiers'] != null) {
          for (var modifier in data['shop']['fixed_modifiers']) {
            _shopConsumables.add(
              PurchasableItemInfo(
                price: modifier['price'],
                id: modifier['id'],
                index: 0, // Assuming index is not available in the event data
                type: "consumable",
                subtype: modifier['modifier_id'],
                cardName: '',
              ),
            );
          }
        }
      });
    });
    wsClient.addEventListener("starting_vouchers", (data) {
      debugPrint("🎴 Received starting voucher phase: $data");
      final timeoutStart = DateTime.parse(data['timeout_start_date']).toLocal();
      final now = DateTime.now();
      final timeout = data['timeout'];
      debugPrint("timeoutStart: $timeoutStart, now: $now");
      debugPrint("Difference: ${timeoutStart.difference(now)}");
      // Calculate how many seconds are left from now until that date
      final timeUntilTimeout = timeout - now.difference(timeoutStart).inSeconds;
      setState(() {
        // Switch to the voucher phase
        _animateShowConsumableFaseWidget = true;
        _showConsumableFaseWidget = true;

        // Hide the shop phase
        _animateShowShopFaseWidgets = false;
        _showShopFaseWidget = false;

        _currentFase = "consumableFase";
        _timeout = timeUntilTimeout;
      });
    });
    // Listen for round start event
    wsClient.addEventListener("starting_round", (data) async {
      debugPrint("📡 Starting round: $data");
      final timeoutStart = DateTime.parse(data['timeout_start_date']).toLocal();
      final now = DateTime.now();
      final timeout = data['timeout'];
      debugPrint("timeoutStart: $timeoutStart, now: $now");
      debugPrint("Difference: ${timeoutStart.difference(now)}");
      // Calculate how many seconds are left from now until that date
      final timeUntilTimeout = timeout - now.difference(timeoutStart).inSeconds;
      final deckSize = data['current_deck_size'] as int;
      final currentPot = data['current_pot'] as int;
      final round = data['round_number'] as int;
      setState(() {
        // Init game fase
        _showChooseBlindFaseWidget = !_showChooseBlindFaseWidget;
        _showGameFaseWidget = !_showGameFaseWidget;
        _animateShowGameFaseWidgets = !_animateShowGameFaseWidgets;
        _animateShowChooseBlindFaseWidget = !_animateShowChooseBlindFaseWidget;
        _currentFase = "gameFase";
        _timeout = timeUntilTimeout;
        _currentDeckSize = deckSize;
        _currentPot = currentPot;
        _round = round;
        _maxRounds = data['max_rounds'];
        _gold = data['players_money'];
      });
    });

    // Listen for a blind
    wsClient.addEventListener("blind_updated", (data) async {
      if (_myBlind > _minBlind) {
        setState(() {
          _blind = data['new_blind'] as int;
        });
      } else {
        setState(() {
          _blind = _minBlind;
        });
      }
    });

    // Listen for the next round
    wsClient.addEventListener("starting_next_blind", (data) async {
      debugPrint("📡 Next round: $data");
      final timeout = data['timeout'] as int;
      final baseBlind = data['base_blind'] as int;
      final timeoutStart = DateTime.parse(data['timeout_start_date']).toLocal();
      final now = DateTime.now();
      debugPrint("timeoutStart: $timeoutStart, now: $now");
      debugPrint("Difference: ${timeoutStart.difference(now)}");
      // Calculate how many seconds are left from now until that date
      final timeUntilTimeout = timeout - now.difference(timeoutStart).inSeconds;
      setState(() {
        // Switch to the game phase
        _animateShowChooseBlindFaseWidget = true;
        _showChooseBlindFaseWidget = true;
        _currentFase = "chooseBlindFase";

        // Hide the shop phase
        _animateShowConsumableFaseWidget = false;
        _showConsumableFaseWidget = false;
        _timeout = timeUntilTimeout;

        _blind = baseBlind;
        _minBlind = baseBlind;
        _score = 0;
        _discardingCards = 3;
        _playingCards = 3;
        _handCards = [];
        _currentDeckSize = 0;
        _remainingCards = 0;
      });
    });

    /// Listen for game end
    wsClient.addEventListener("game_end", (data) async {
      debugPrint("📡 Received game end: $data");

      final List<dynamic> winners = data['winners'] ?? [];

      // Check if I am the winner
      final bool isWinner = winners.any((winnerData) {
        return winnerData['winner_username'] == widget.hostName;
      });

      await Future.delayed(const Duration(milliseconds: 5000));
      wsClient.disconnect();
      if (!mounted) return;
      useWinLoseDialog(context, isWinner);
    });

    /// Listen for players eliminated
    wsClient.addEventListener("players_eliminated", (data) async {
      debugPrint("📡 Received players eliminated: $data");

      final eliminatedPlayers = List<String>.from(data['eliminated_players']);

      if (eliminatedPlayers.contains(widget.hostName)) {
        await Future.delayed(const Duration(milliseconds: 1000));
        wsClient.disconnect();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: const HomeScreen(),
          ),
        );
      }
    });
  }

  /// Updates the visibility and animation flags based on the current game phase.
  void _updatePhaseWidgets(String phase) {
    setState(() {
      // Reset all animation flags to false first
      _animateShowChooseBlindFaseWidget = false;
      _animateShowGameFaseWidgets = false;
      _animateShowShopFaseWidgets = false;
      _animateShowConsumableFaseWidget = false;

      // Reset all visibility flags to false
      _showChooseBlindFaseWidget = false;
      _showGameFaseWidget = false;
      _showShopFaseWidget = false;
      _showConsumableFaseWidget = false;

      // Update flags based on the current phase
      switch (phase) {
        case "blind":
          _animateShowChooseBlindFaseWidget = true;
          _showChooseBlindFaseWidget = true;
          _currentFase = "chooseBlindFase";
          break;
        case "play_round":
          _animateShowGameFaseWidgets = true;
          _showGameFaseWidget = true;
          _currentFase = "gameFase";
          break;
        case "shop":
          _animateShowShopFaseWidgets = true;
          _showShopFaseWidget = true;
          _currentFase = "shopFase";
          break;
        case "vouchers":
          _animateShowConsumableFaseWidget = true;
          _showConsumableFaseWidget = true;
          _currentFase = "consumableFase";
          break;
        case "announce_winner":
          break;
      }
    });
  }

  void onAddConsumableOwned(PurchasableItemInfo jokerInfo) {
    consumablesOwned.add(jokerInfo);
  }

  void onRemoveConsumableOwned(PurchasableItemInfo jokerInfo) {
    if (consumablesOwned.isNotEmpty) {
      consumablesOwned.remove(jokerInfo);
    }
  }

  void onAddConsumableUsed(PurchasableItemInfo jokerInfo) {
    consumablesUsed.add(jokerInfo);
  }

  void onRemoveConsumableUsed(PurchasableItemInfo jokerInfo) {
    if (consumablesUsed.isNotEmpty) {
      consumablesUsed.remove(jokerInfo);
    }
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
                    ownedConsumableCardsKey: _ownedConsumableCardsKey,
                    usedConsumableCardsKey: _usedConsumableCardsKey,
                    shopWidgetKey: _shopWidgetKey,
                    buyWidgetKey: _buyWidgetKey,
                    useConsumableWidgetKey: _useConsumableWidgetKey,
                    shopFaseWidgetKey: _shopFaseWidgetKey,
                    consumableFaseWidgetKey: _consumableFaseWidgetKey,
                    sellWidgetKey: _sellWidgetKey,
                    consumableOwned: consumablesOwned,
                    onAddConsumableOwned: (value) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          onAddConsumableOwned(value);
                        });
                      });
                    },
                    onRemoveConsumableOwned: (value) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          onRemoveConsumableOwned(value);
                        });
                      });
                    },
                    consumableUsed: consumablesUsed,
                    onAddConsumableUsed: (value) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          onAddConsumableUsed(value);
                        });
                      });
                    },
                    onRemoveConsumableUsed: (value) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          onRemoveConsumableUsed(value);
                        });
                      });
                    },
                    round: _round,
                    discardingCards: _discardingCards,
                    playingCards: _playingCards,
                    currentFase: _currentFase,
                    isShopPhase: _showShopFaseWidget,
                    score: _score,
                    blueScore: _blueScore,
                    redScore: _redScore,
                    handType: _handType,
                    gold: _gold,
                    currentPot: _currentPot,
                    blind: _blind,
                    maxRounds: _maxRounds,
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
                                jokersOwned: _jokersOwned,
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
                                minBlind: _minBlind,
                                onBlind: (value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _myBlind = value;
                                    });
                                  });
                                },
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
                                  _playedCards = playedCards;
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
                                    if (!mounted) return;
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
                                blind: _blind,
                                handCards: _handCards,
                                jokerCardsKey: _jokerCardsKey,
                                gold: _gold,
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
                                consumableCardsKey: _ownedConsumableCardsKey,
                                sellWidgetKey: _sellWidgetKey,
                                onBuy: (value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _gold = value;
                                    });
                                  });
                                },
                                onSell: (value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _gold = value;
                                    });
                                  });
                                },
                                onReroll: (value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _gold = value;
                                    });
                                  });
                                },
                                shopJokers: _shopJokers,
                                gold: _gold,
                                shopConsumables: _shopConsumables,
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
                                consumableOwned: consumablesOwned,
                                onAddConsumableOwned: (value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      onAddConsumableOwned(value);
                                    });
                                  });
                                },
                                onRemoveConsumableOwned: (value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      onRemoveConsumableOwned(value);
                                    });
                                  });
                                },
                                ownedConsumableCardsKey:
                                    _ownedConsumableCardsKey,
                                usedConsumableCardsKey: _usedConsumableCardsKey,
                                shopWidgetKey: _shopWidgetKey,
                                buyWidgetKey: _buyWidgetKey,
                                shopFaseWidgetKey: _shopFaseWidgetKey,
                                consumableFaseWidgetKey:
                                    _consumableFaseWidgetKey,
                                sellWidgetKey: _sellWidgetKey,
                                useConsumableWidgetKey: _useConsumableWidgetKey,
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
