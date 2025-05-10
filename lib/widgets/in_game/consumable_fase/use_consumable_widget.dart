import 'package:flutter/material.dart';
import 'package:nogler/dialogs/game_dialogs.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';

class UseConsumableWidget extends StatefulWidget {
  const UseConsumableWidget({
    super.key,
    required this.ownedConsumableCardsKey,
    required this.usedConsumableCardsKey,
    required this.lobbyUsers,
    required this.ownKey,
  });

  final GlobalKey<OwnedConsumableCardsState> ownedConsumableCardsKey;
  final GlobalKey<UsedConsumableCardsState> usedConsumableCardsKey;
  final GlobalKey<UseConsumableWidgetState> ownKey;
  final List<Map<String, dynamic>> lobbyUsers;

  @override
  UseConsumableWidgetState createState() => UseConsumableWidgetState();
}

class UseConsumableWidgetState extends State<UseConsumableWidget> {
  final WebSocketClient wsClient = WebSocketClient();

  // Initialized because the compiler is mad
  PurchasableItemInfo draggedItem = PurchasableItemInfo(
    price: 0,
    id: -1,
    index: -1,
    type: "",
    subtype: 0,
    rank: '',
    suit: '',
    overlay: 0,
  );

  // Get the info of dragged item
  Future<void> setDraggedItem(PurchasableItemInfo currentDragged) async {
    setState(() {
      draggedItem = currentDragged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white),
      ),
      // Make the container receive draggable cards
      child: DragTarget<PurchasableItemInfo>(
        onAcceptWithDetails: (DragTargetDetails<PurchasableItemInfo> dragged) {
          switch (dragged.data.type) {
            case "owned consumable":

              // Use consumable for your own
              if (consumablesMap[dragged.data.subtype]['consumableTargets'] ==
                  "0") {
                List<int> voucher = [];
                voucher.add(dragged.data.subtype);
                wsClient.sendMessage("activate_modifiers", {
                  [voucher],
                });
                widget.ownedConsumableCardsKey.currentState
                    ?.removeConsumableOwned(dragged.data);
              }
              // Use consumable to molest others
              else {
                showUseConsumableDialog(
                  context,
                  dragged.data,
                  int.parse(
                    consumablesMap[dragged.data.subtype]['consumableTargets'] ??
                        "-1",
                  ),
                  widget.ownKey,
                  widget.lobbyUsers,
                  () {
                    widget.ownedConsumableCardsKey.currentState
                        ?.removeConsumableOwned(dragged.data);
                  },
                );
              }
              break;
          }
        },
        builder: (
          BuildContext context,
          List<dynamic> accepted,
          List<dynamic> rejected,
        ) {
          // Use text widget
          return Center(
            child: Text(
              "Use",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}
