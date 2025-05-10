import 'package:flutter/material.dart';
import 'package:nogler/dialogs/game_dialogs.dart';
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
    required this.shopPackages,
    required this.currentPot,
    required this.priceReroll,
    required this.lobbyUsers,
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
  final List<PurchasableItemInfo> shopPackages;
  final int currentPot;
  final int priceReroll;
  final List<Map<String, dynamic>> lobbyUsers;
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

  bool _showJokerPoints = false;
  double relativePositionJokerPoints = 50;

  bool _newChatMessage = false;

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
  int _minBlind = 0;
  int _round = 0;
  int _maxRounds = 0;
  List<SelectableCard> _playedCards = [];
  List<PurchasableItemInfo> _shopJokers = [];
  List<PurchasableItemInfo> _shopConsumables = [];
  List<PurchasableItemInfo> _shopPackages = [];
  int _priceReroll = 0;
  @override
  void initState() {
    super.initState();
    lobbyUsers = widget.lobbyUsers;
    _priceReroll = widget.priceReroll;
    _currentPot = widget.currentPot;
    _shopConsumables = widget.shopConsumables;
    _shopPackages = widget.shopPackages;
    consumablesOwned = widget.consumablesOwned;
    consumablesUsed = widget.consumablesUsed;
    _maxRounds = widget.maxRounds;
    _jokersOwned = widget.jokersOwned;
    _handCards = widget.handCards;
    _blind = widget.baseBlind;
    _minBlind = widget.baseBlind;
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
        if (chatMessages.last["username"] != widget.hostName) {
          _newChatMessage = true;
        }
      });

      debugPrint("🟩 Total messages: ${chatMessages.length}");
    });
    // Listen for lobby info
    /*
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
    */
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
      final timeUntilTimeout =
          timeout - (now.difference(timeoutStart).inSeconds).abs();
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
        _shopPackages = [];
        _priceReroll = data['next_reroll_price'];
        // Extracting jokers from the event data
        if (data['shop']['rerolled_items'] != null) {
          for (var item in data['shop']['rerolled_items']) {
            if (item['jokers'] != null) {
              for (var joker in item['jokers']) {
                _shopJokers.add(
                  PurchasableItemInfo(
                    price: joker['price'],
                    id: joker['id'],
                    index: 0,
                    type: joker['type'],
                    subtype: joker['joker_id'],
                    rank: '',
                    suit: '',
                    overlay: 0,
                  ),
                );
              }
            }
          }
        }

        // Extracting packs from the event data
        if (data['shop']['fixed_packs'] != null) {
          for (var pack in data['shop']['fixed_packs']) {
            _shopPackages.add(
              PurchasableItemInfo(
                price: pack['price'],
                id: pack['id'],
                index: 0,
                type: 'package',
                subtype: pack['pack_type'],
                rank: '',
                suit: '',
                overlay: 0,
              ),
            );
          }
        }

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
                rank: '',
                suit: '',
                overlay: 0,
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
      final timeUntilTimeout =
          timeout - (now.difference(timeoutStart).inSeconds).abs();
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
      final timeUntilTimeout =
          timeout - (now.difference(timeoutStart).inSeconds).abs();
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
        _blind = data['blind'];
        _handCards = [];
      });
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
      final timeUntilTimeout =
          timeout - (now.difference(timeoutStart).inSeconds).abs();
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
      final int points = data['winners']['points'];

      final time = _playedCards.where((card) => card.isScored).length + 1;
      await Future.delayed(Duration(seconds: time));
      wsClient.disconnect();
      if (!mounted) return;
      useWinLoseDialog(context, isWinner, points);
    });

    /// Listen for players eliminated
    wsClient.addEventListener("players_eliminated", (data) async {
      debugPrint("📡 Received players eliminated: $data");

      final eliminatedPlayers = List<String>.from(data['eliminated_players']);
      bool isWinner = false;
      isWinner = !eliminatedPlayers.contains(widget.hostName);
      final int points = data['high_blind_value'];
      if (!isWinner) {
        final time = _playedCards.where((card) => card.isScored).length + 1;
        await Future.delayed(Duration(seconds: time));
        wsClient.disconnect();
        if (!mounted) return;
        useWinLoseDialog(context, isWinner, points);
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

  void onScore(int index) {
    debugPrint("Inicio Animacion game_screen $index ");
    setState(() {
      _showJokerPoints = !_showJokerPoints;
      relativePositionJokerPoints = 215.0 + (60.0 * index);
    });
    debugPrint("Animacion game_screen $index ");
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
              // Show the message "Activated!" when a joker is triggered
              Visibility(
                visible: _showJokerPoints,
                child: Positioned(
                  top: 90,
                  left: relativePositionJokerPoints,
                  child: Text(
                    "Activated!",
                    style: TextStyle(color: Colors.yellow, fontSize: 14),
                  ),
                ),
              ),
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
                          child: Stack(
                            children: [
                              Visibility(
                                visible: false,
                                child: Positioned(
                                  top: 50,
                                  left: 10,
                                  child: Container(
                                    height: 200,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Text(
                                      "+2",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 40,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Jokers
                              Row(
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
                                    onScore: onScore,
                                  ),
                                ],
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
                                onBlind: (value) {},
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
                                onPlayCards: (playedCards, jokersTriggered) {
                                  _playedCards = playedCards;
                                  _selectedCardsKey.currentState?.showCards(
                                    playedCards,
                                    jokersTriggered,
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
                                onReroll: (value, value2) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _priceReroll = value;
                                      _gold = value2;
                                    });
                                  });
                                },
                                shopJokers: _shopJokers,
                                gold: _gold,
                                shopConsumables: _shopConsumables,
                                shopPackages: _shopPackages,
                                priceReroll: _priceReroll,
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
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(12),
                          ),
                          onPressed: () {
                            setState(() {
                              _newChatMessage = false;
                              debugPrint(
                                "Eliminada notificacion nuevo mensaje: $_newChatMessage",
                              );
                            });
                            _scaffoldKey.currentState?.openEndDrawer();
                          },
                          child: const Icon(
                            Icons.chat_bubble,
                            color: Colors.black,
                          ),
                        ),
                        Visibility(
                          visible: _newChatMessage,
                          child: Positioned(
                            left: 46,
                            child: Icon(Icons.circle, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),

                    SettingsButton(
                      onPressed: () {
                        wsClient.sendMessage('exit_lobby', widget.lobbyCode);
                        wsClient.disconnect();
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
