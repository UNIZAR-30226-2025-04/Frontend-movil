import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/consumable_fase/use_consumable_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/sell_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_fase_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';

class ConsumableFaseWidget extends StatefulWidget {
  const ConsumableFaseWidget({
    super.key,
    required this.consumableOwned,
    required this.onAddConsumableOwned,
    required this.onRemoveConsumableOwned,
    required this.shopWidgetKey,
    required this.buyWidgetKey,
    required this.ownedConsumableCardsKey,
    required this.usedConsumableCardsKey,
    required this.shopFaseWidgetKey,
    required this.consumableFaseWidgetKey,
    required this.sellWidgetKey,
    required this.useConsumableWidgetKey,
    required this.lobbyUsers,
  });

  final List<PurchasableItemInfo> consumableOwned;
  final Function(PurchasableItemInfo)? onAddConsumableOwned;
  final Function(PurchasableItemInfo)? onRemoveConsumableOwned;
  final GlobalKey<OwnedConsumableCardsState> ownedConsumableCardsKey;
  final GlobalKey<UsedConsumableCardsState> usedConsumableCardsKey;
  final GlobalKey<ShopWidgetState> shopWidgetKey;
  final GlobalKey<BuyWidgetState> buyWidgetKey;
  final GlobalKey<ShopFaseWidgetState> shopFaseWidgetKey;
  final GlobalKey<ConsumableFaseWidgetState> consumableFaseWidgetKey;
  final GlobalKey<SellWidgetState> sellWidgetKey;
  final GlobalKey<UseConsumableWidgetState> useConsumableWidgetKey;
  final List<Map<String, dynamic>> lobbyUsers;

  @override
  ConsumableFaseWidgetState createState() => ConsumableFaseWidgetState();
}

class ConsumableFaseWidgetState extends State<ConsumableFaseWidget> {
  List<Map<String, dynamic>> lobbyUsers = [];
  bool hasFetched = true;

  bool useConsumableWidgetVisible = false;
  final WebSocketClient wsClient = WebSocketClient();

  Future<void> onDraggedConsumable() async {
    setState(() {
      useConsumableWidgetVisible = true;
    });
  }

  Future<void> onDroppedConsumable() async {
    setState(() {
      useConsumableWidgetVisible = false;
    });
  }

  @override
  void initState() {
    super.initState();

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
      debugPrint("Players currently on the lobby $lobbyUsers");
    });
  }

  Future<void> getLobbyInfo() async {
    // Get the code of the lobby in local storage
    final lobbyCode = await const FlutterSecureStorage().read(key: 'code');

    // Ask for lobby info
    wsClient.sendMessage("get_lobby_info", lobbyCode);
  }

  @override
  Widget build(BuildContext context) {
    // Get the lobby info
    if (hasFetched) {
      getLobbyInfo();
      hasFetched = false;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Hide the use widget if there's no consumable dragged
        !useConsumableWidgetVisible
            ? SizedBox(height: 100)
            : Visibility(
              visible: useConsumableWidgetVisible,
              child: UseConsumableWidget(
                ownedConsumableCardsKey: widget.ownedConsumableCardsKey,
                usedConsumableCardsKey: widget.usedConsumableCardsKey,
                lobbyUsers: lobbyUsers,
                ownKey: widget.useConsumableWidgetKey,
              ),
            ),

        // Space between
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OwnedConsumableCards(
              key: widget.ownedConsumableCardsKey,
              consumableOwned: widget.consumableOwned,
              onAddConsumableOwned: widget.onAddConsumableOwned,
              onRemoveConsumableOwned: widget.onRemoveConsumableOwned,
              shopFaseWidgetKey: widget.shopFaseWidgetKey,
              consumableFaseWidgetKey: widget.consumableFaseWidgetKey,
              shopWidgetKey: widget.shopWidgetKey,
              buyWidgetKey: widget.buyWidgetKey,
              sellWidgetKey: widget.sellWidgetKey,
            ),
          ],
        ),

        // Space between
        SizedBox(height: 5),
        ElevatedButton(
          onPressed: () {
            wsClient.sendMessage("continue_to_next_blind", {});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFd41976),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                16,
              ), // Smooth the border shape
            ),
            minimumSize: const Size(50, 50),
          ),
          child: const Text(" Next Round"),
        ),
      ],
    );
  }
}
