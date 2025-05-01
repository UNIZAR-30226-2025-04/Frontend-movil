import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nogler/data/api/lobby_api.dart';
import 'package:nogler/data/api/party_api.dart';
import 'package:nogler/data/api/users_api.dart';
import 'package:nogler/dialogs/friends_dialogs.dart';
import 'package:nogler/dialogs/lobby_dialogs.dart';
import 'package:nogler/dialogs/party_dialog.dart';
import 'package:nogler/dialogs/profile_dialog.dart';
import 'package:nogler/screens/home/game_screen.dart';
import 'package:nogler/screens/home/join_lobby_screen.dart';

import 'package:flutter/material.dart';
import 'package:nogler/screens/loading/loading_screen.dart';
import 'package:nogler/screens/lobby/lobby_screen.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/background_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/in_game/main_cards_widget.dart';
import 'package:page_transition/page_transition.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Home screen of the application
class _HomeScreenState extends State<HomeScreen> {
  String _username = "Loading...";
  int _avatar = 1;
  final WebSocketClient wsClient = WebSocketClient();
  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Obtain user profile information
    _initLobbyStatus();
  }

  /// Method to load the user profile information
  Future<void> _loadUserProfile() async {
    // Pass a callback to loadUserProfile
    loadUserProfile((String username, int avatar) {
      setState(() {
        _username = username; // Update the username
        _avatar = avatar; // Update the avatar
      });
    });
  }

  /// Method to load the user profile information
  Future<void> _playAgainstIA() async {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: const LoadingScreen(
          loadingMessage: 'Getting your match against the AI ready...',
        ),
      ),
    );
    createLobby((String code) async {
      // Store the code in secure storage
      await joinLobby(code);
      await const FlutterSecureStorage().write(key: 'code', value: code);
      // Auto-connect when screen loads
      await wsClient.initialize();
      wsClient.addEventListener("lobby_info", (data) {
        wsClient.sendMessage("start_game", code);
      });
      // Listen for game start event
      wsClient.addEventListener("starting_next_blind", (data) async {
        debugPrint("📡 Starting round: $data");
        final baseBlind = data['base_blind'] as int;
        final timeoutStart =
            DateTime.parse(data['timeout_start_date']).toLocal();
        final now = DateTime.now();
        final timeout = data['timeout'] as int;
        debugPrint("timeoutStart: $timeoutStart, now: $now");
        debugPrint("Difference: ${timeoutStart.difference(now)}");
        // Calculate how many seconds are left from now until that date
        final timeUntilTimeout = timeout - now.difference(timeoutStart).inSeconds;
        Navigator.of(context).pushReplacement(
          PageTransition(
            type: PageTransitionType.fade,
            child: GameScreen(
              round: 1,
              hostName: _username,
              hostAvatar: _avatar,
              lobbyCode: code,
              timeout: timeUntilTimeout,
              phase: "blind",
              baseBlind: baseBlind,
              discardingCards: 3,
              playingCards: 3,
              handCards: [],
              currentPoints: 0,
              currentDeckSize: 0,
              remainingCards: 0,
              jokersOwned: [],
              shopJokers: [],
              gold: 0,
              myBlind: 0,
              maxRounds: 0,
              consumablesOwned: [],
              shopConsumables: [],
              consumablesUsed: [],
            ),
          ),
        );
      });
    }, '2'); // Create the lobby with the selected privacy
  }

  // Method to check if the user is in a lobby and initialize WebSocket if true
  Future<void> _initLobbyStatus() async {
    final result = await checkIfInLobby();
    if (result["in_lobby"] == true) {
      if (!mounted) return;
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: const LoadingScreen(
            loadingMessage: 'Resuming your previous game...',
          ),
        ),
      );

      await wsClient.initialize();
      wsClient.addEventListener("game_phase_player_info", (data) {
        wsClient.removeEventListener("error");
        debugPrint("👤 New user joined: $data");
        final round = data['current_round'] as int? ?? 0;
        final parsedList =
            (data['player_data']['current_hand'] as List<dynamic>?) ?? [];
        final playerData = data['player_data'] ?? {};
        final discardsLeft = playerData['discards_left'] ?? 0;
        final playsLeft = playerData['hand_plays_left'] ?? 0;
        final currentPoints = playerData['current_points'] ?? 0;
        final playedCards = playerData['played_cards'] ?? 0;
        final unplayedCards = playerData['unplayed_cards'] ?? 0;

        if (data['phase'] == 'none') {
          wsClient.sendMessage("get_lobby_info", result["lobby_id"]);
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: LobbyScreen(
                  hostName: _username,
                  hostAvatar: _avatar,
                  lobbyState: result["private"],
                  lobbyCode: result["lobby_id"],
                ),
              ),
            );
          }
        } else {
          if (context.mounted) {
            List<PurchasableItemInfo> jokersOwned = [];
            List<PurchasableItemInfo> shopJokers = [];
            List<PurchasableItemInfo> consumablesOwned = [];
            List<PurchasableItemInfo> shopConsumables = [];
            List<PurchasableItemInfo> consumablesUsed = [];
            if (data['phase'] == 'shop') {
              // Parse owned jokers with correct id from shop items
              final rerollableItems =
                  data['shop_items']['rerollable_items'] as List<dynamic>? ??
                  [];
              jokersOwned =
                  (data['player_data']['current_jokers'] as List<dynamic>?)?.map((
                    jokerData,
                  ) {
                    // Find the matching joker in rerollable_items where 'joker_id' matches the current_joker's 'id'
                    final matchingShopJoker = rerollableItems.firstWhere(
                      (shopJoker) => shopJoker['joker_id'] == jokerData['id'],
                      orElse: () => null,
                    );

                    return PurchasableItemInfo(
                      price: jokerData['sell_price'] ?? 0,
                      id:
                          matchingShopJoker != null
                              ? matchingShopJoker['id']
                              : -1,
                      index: -1,
                      type: "owned joker",
                      subtype: jokerData['id'],
                      cardName: '',
                    );
                  }).toList() ??
                  [];

              // Parse the shop jokers from rerollable_items

              for (var joker in data['shop_items']['rerollable_items']) {
                shopJokers.add(
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

              // Filter: remove from shopJokers the jokers already owned
              shopJokers.removeWhere(
                (shopConsumable) => jokersOwned.any(
                  (ownedJoker) => ownedJoker.id == shopConsumable.id,
                ),
              );

              // Parse owned consumables with correct id from shop items
              final fixedModifiers =
                  data['shop_items']['fixed_modifiers'] as List<dynamic>? ?? [];
              consumablesOwned =
                  (data['player_data']['vouchers']?['Modificadores']
                          as List<dynamic>?)
                      ?.map((consumableData) {
                        // Find the matching joker in fixed_modifiers where 'modifier_id' matches the modifiers's 'value'
                        final matchingShopJoker = fixedModifiers.firstWhere(
                          (shopConsumable) =>
                              shopConsumable['modifier_id'] ==
                              consumableData['value'],
                          orElse: () => null,
                        );

                        return PurchasableItemInfo(
                          price: 0,
                          id:
                              matchingShopJoker != null
                                  ? matchingShopJoker['id']
                                  : -1,
                          index: -1,
                          type: "owned consumable",
                          subtype: consumableData['value'],
                          cardName: '',
                        );
                      })
                      .toList() ??
                  [];

              // Parse the shop jokers from rerollable_items

              for (var consumable in data['shop_items']['fixed_modifiers']) {
                shopConsumables.add(
                  PurchasableItemInfo(
                    price: consumable['price'],
                    id: consumable['id'],
                    index: 0,
                    type: consumable['type'],
                    subtype: consumable['modifier_id'],
                    cardName: '',
                  ),
                );
              }

              // Filter: remove from shopJokers the jokers already owned
              shopConsumables.removeWhere(
                (shopConsumable) => consumablesOwned.any(
                  (ownedConsumable) => ownedConsumable.id == shopConsumable.id,
                ),
              );
            } else {
              jokersOwned =
                  (data['player_data']['current_jokers'] as List<dynamic>?)?.map((
                    jokerData,
                  ) {
                    return PurchasableItemInfo(
                      price: jokerData['sell_price'] ?? 0,
                      id: 0,
                      index: -1,
                      type: "owned joker",
                      subtype:
                          jokerData['id'], // subtype sigue siendo el id original
                      cardName: '',
                    );
                  }).toList() ??
                  [];
              consumablesOwned =
                  (data['player_data']['vouchers']?['Modificadores']
                          as List<dynamic>?)
                      ?.map((consumableData) {
                        return PurchasableItemInfo(
                          price: 0,
                          id: 0,
                          index: -1,
                          type: "owned consumable",
                          subtype: consumableData['value'],
                          cardName: '',
                        );
                      })
                      .toList() ??
                  [];
            }
            consumablesUsed =
                (data['player_data']['active_vouchers']?['Modificadores']
                        as List<dynamic>?)
                    ?.map((consumableData) {
                      return PurchasableItemInfo(
                        price: 0,
                        id: 0,
                        index: -1,
                        type: "owned consumable",
                        subtype: consumableData['value'],
                        cardName: '',
                      );
                    })
                    .toList() ??
                [];
            final handCards =
                parsedList.map((cardData) {
                  final card = MainCardsState().createCardFromServerData(
                    cardData,
                  );
                  return card;
                }).toList();
            final timeoutStart = DateTime.parse(data['timeout']).toLocal();
            final now = DateTime.now();
            debugPrint("timeoutStart: $timeoutStart, now: $now");
            debugPrint("Difference: ${timeoutStart.difference(now)}");
            // Calculate how many seconds are left from now until that date
            final timeUntilTimeout = now.difference(timeoutStart).inSeconds;
            Navigator.of(context).pushReplacement(
              PageTransition(
                type: PageTransitionType.fade,
                child: GameScreen(
                  round: round,
                  hostName: _username,
                  hostAvatar: _avatar,
                  lobbyCode: result["lobby_id"],
                  timeout: timeUntilTimeout,
                  phase: data['phase'],
                  baseBlind: data['current_base_blind'] ?? 0,
                  discardingCards: discardsLeft,
                  playingCards: playsLeft,
                  handCards: handCards,
                  currentPoints: currentPoints,
                  currentDeckSize: playedCards + unplayedCards,
                  remainingCards: unplayedCards - 8,
                  jokersOwned: jokersOwned,
                  shopJokers: shopJokers,
                  gold: data['player_data']['players_money'],
                  myBlind: data['player_data']['actual_current_bet'],
                  maxRounds: data['max_rounds'],
                  shopConsumables: shopConsumables,
                  consumablesOwned: consumablesOwned,
                  consumablesUsed: consumablesUsed,
                ),
              ),
            );
          }
        }
      });
      wsClient.addEventListener("error", (data) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading screen
          // Show a error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(
                child: Text(
                  'Connection error',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              duration: Duration(seconds: 3),
            ),
          );
          wsClient.disconnect();
        }
      });
      wsClient.addEventListener("lobby_info", (data) {
        wsClient.sendMessage(
          "request_game_phase_player_info",
          result["lobby_id"],
        );
        wsClient.removeEventListener("lobby_info");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // Scaffold widget to create the screen
      body: BackgroundWidget(
        // Background image for the screen
        child: SafeArea(
          // SafeArea widget to avoid overlapping with the system status bar
          child: Column(
            // Column widget to stack elements vertically
            children: [
              Padding(
                // Adds padding around the profile button
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  // Aligns the profile button to the top right
                  alignment: Alignment.topRight,
                  child: _buildProfileButton(context, _username),
                ),
              ),

              Expanded(
                // Expanded widget to take up the remaining space
                child: Center(
                  child: Image.asset('images/nogler.png', width: 250),
                ),
              ),

              Padding(
                // Adds padding around the menu buttons
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20,
                ),
                child: Container(
                  // Container to hold the menu buttons
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3454),
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                    border: Border.all(color: Colors.white), // Black border
                  ),
                  child: Wrap(
                    // Wrap widget to create a flow of buttons
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center, // Centers the buttons
                    children: [
                      _buildMenuButton(context, 'VS AI', () async {
                        _playAgainstIA();
                      }),

                      _buildMenuButton(context, 'JOIN', () {
                        Navigator.pushReplacement(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: JoinLobbyScreen(
                              hostName: _username,
                              hostAvatar: _avatar,
                            ),
                          ),
                        );
                      }),
                      _buildMenuButton(context, 'HOST', () {
                        showCreateLobbyButton(
                          context,
                          _username,
                          _avatar,
                        ); //TODO, decision de hacerlo por parametro o por peticion a back
                      }),
                      _buildMenuButton(context, 'PARTY', () {
                        showPartyList(context, _username);
                      }),
                      _buildMenuButton(context, 'FRIENDS', () {
                        showFriendsList(context, _username);
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget to create a menu button
  Widget _buildMenuButton(
    BuildContext context,
    String title,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 120,
      height: 50,
      child: ElevatedButton(
        // ElevatedButton widget for the menu button
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C3454),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ), // Rounded corners
          side: BorderSide(
            color: Colors.white,
            width: 1, // White border
          ),
        ),
        onPressed: onPressed, // Calls the provided function when pressed
        child: Text(
          // Text inside the button
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Widget to create the profile button
  Widget _buildProfileButton(BuildContext context, String username) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // Style of the button
        backgroundColor: const Color(0xFF2C3454),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.white,
            width: 1, // White border
          ),
        ), // Rounded edges
      ),
      onPressed: () async {
        // Function to execute when the button is pressed
        // Show the profile dialog and wait for the result
        final result = await showProfile(context, _username, _avatar);
        if (result == true) {
          _loadUserProfile(); // Reload the user profile
        }
      }, // Empty function for now
      child: Column(
        // Column to stack text and username box vertically
        mainAxisSize: MainAxisSize.min, // Minimize the size of the column
        children: [
          const Text(
            // Text inside the button
            "Profile",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(width: 8), // Space between text and username box
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ), // Padding inside the box
            decoration: BoxDecoration(
              color: const Color(0xFF2C3454),
              borderRadius: BorderRadius.circular(8), // Rounded corners
              border: Border.all(color: Colors.white), // Black border
            ),
            child: Text(
              // Username text inside the box
              username,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
