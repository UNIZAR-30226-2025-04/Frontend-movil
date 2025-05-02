import 'package:flutter/material.dart';

import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';

class BuyWidget extends StatefulWidget {
  const BuyWidget({
    super.key,
    required this.shopWidgetKey,
    required this.jokerCardsKey,
    required this.consumableCardsKey,
    required this.onBuy,
    required this.gold,
  });

  final GlobalKey<ShopWidgetState> shopWidgetKey;
  final GlobalKey<JokerCardsState> jokerCardsKey;
  final GlobalKey<OwnedConsumableCardsState> consumableCardsKey;
  final Function(int)? onBuy;
  final int gold;

  @override
  BuyWidgetState createState() => BuyWidgetState();
}

class BuyWidgetState extends State<BuyWidget> {
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
  // Websocket client
  final WebSocketClient wsClient = WebSocketClient();
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
        onAcceptWithDetails: (
          DragTargetDetails<PurchasableItemInfo> dragged,
        ) async {
          switch (dragged.data.type) {
            case "joker":
              if (widget.gold >= dragged.data.price &&
                  widget.jokerCardsKey.currentState!.jokersOwned.length < 5) {
                wsClient.sendMessage(
                  "buy_joker",
                  dragged.data.id,
                  dragged.data.price,
                );
                widget.shopWidgetKey.currentState?.removeJoker(
                  dragged.data.index,
                  false,
                );
              }
              break;
            case "consumable":
              if (widget.gold >= dragged.data.price) {
                wsClient.sendMessage(
                  "buy_voucher",
                  dragged.data.id,
                  dragged.data.price,
                );
                widget.shopWidgetKey.currentState?.removeConsumable(
                  dragged.data.index,
                  false,
                );
              }
              break;
            case "package":
              // Agregar debug para verificar los valores de id y price
              debugPrint(
                "Enviando mensaje con ID: ${dragged.data.id}, Precio: ${dragged.data.price}",
              );

              if (widget.gold >= dragged.data.price &&
                  (dragged.data.subtype != 2 ||
                      widget.jokerCardsKey.currentState!.jokersOwned.length <
                          5)) {
                wsClient.sendMessage(
                  "buy_pack",
                  dragged.data.id,
                  dragged.data.price,
                );
                widget.shopWidgetKey.currentState?.removePackage(
                  dragged.data.index,
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
          // Buy text widget
          return Center(
            child: Text(
              "Buy\n\$ ${draggedItem.price}",
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
