import 'package:flutter/material.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';

class SellWidget extends StatefulWidget {
  const SellWidget({
    super.key,
    required this.jokerCardsKey,
    required this.consumableCardsKey,
    required this.onSell,
  });

  final GlobalKey<JokerCardsState> jokerCardsKey;
  final GlobalKey<OwnedConsumableCardsState> consumableCardsKey;
  final Function(int)? onSell;
  @override
  SellWidgetState createState() => SellWidgetState();
}

class SellWidgetState extends State<SellWidget> {
  final WebSocketClient wsClient = WebSocketClient();
  // Initialized because the compiler is mad
  PurchasableItemInfo draggedItem = PurchasableItemInfo(
    price: 0,
    id: -1,
    index: -1,
    type: "",
    subtype: 0,
    cardName: "",
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
      width: 100,
      height: 220,
      margin: const EdgeInsets.fromLTRB(16, 16, 0, 0),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white),
      ),
      child: DragTarget<PurchasableItemInfo>(
        onAcceptWithDetails: (DragTargetDetails<PurchasableItemInfo> dragged) {
          switch (dragged.data.type) {
            case "owned joker":
              wsClient.sendMessage("sell_joker", {dragged.data.subtype});
              widget.jokerCardsKey.currentState?.removeJokerOwned(dragged.data);

              break;
          }
        },
        builder: (
          BuildContext context,
          List<dynamic> accepted,
          List<dynamic> rejected,
        ) {
          // Sell text widget
          return Center(
            child: Text(
              "Sell\n\$ ${draggedItem.price}",
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
