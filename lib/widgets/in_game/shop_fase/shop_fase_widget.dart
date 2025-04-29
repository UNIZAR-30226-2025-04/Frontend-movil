import 'package:flutter/material.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/sell_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';

class ShopFaseWidget extends StatefulWidget {
  const ShopFaseWidget({
    super.key,
    required this.shopWidgetKey,
    required this.buyWidgetKey,
    required this.jokerCardsKey,
    required this.consumableCardsKey,
    required this.sellWidgetKey,
    required this.onBuy,
    required this.onSell,
    required this.onReroll,
    required this.shopJokers,
    required this.gold,
    required this.shopConsumables,
  });

  final GlobalKey<ShopWidgetState> shopWidgetKey;
  final GlobalKey<JokerCardsState> jokerCardsKey;
  final GlobalKey<OwnedConsumableCardsState> consumableCardsKey;
  final GlobalKey<BuyWidgetState> buyWidgetKey;
  final GlobalKey<SellWidgetState> sellWidgetKey;
  final Function(int)? onBuy;
  final Function(int)? onSell;
  final Function(int)? onReroll;
  final List<PurchasableItemInfo> shopJokers;
  final int gold;
  final List<PurchasableItemInfo> shopConsumables;

  @override
  State<ShopFaseWidget> createState() => ShopFaseWidgetState();
}

class ShopFaseWidgetState extends State<ShopFaseWidget> {
  bool buyWidgetVisible = false;
  bool sellWidgetVisible = false;
  // Websocket client
  final WebSocketClient wsClient = WebSocketClient();
  Future<void> onDraggedItem() async {
    setState(() {
      buyWidgetVisible = true;
    });
  }

  @override
  void initState() {
    super.initState();

    // Listerner for a bought joker
    wsClient.addEventListener("joker_purchased", (data) {
      int itemId = data["item_id"];
      int jokerId = data["joker_id"];
      int sellPrice = data["sell_price"];
      int remainingMoney = data["remaining_money"];

      // Create the new PurchasableItemInfo
      PurchasableItemInfo purchasedJoker = PurchasableItemInfo(
        price: sellPrice,
        id: itemId,
        index: -1,
        type: "owned joker",
        subtype: jokerId,
        cardName: "",
      );

      widget.jokerCardsKey.currentState?.addJokerOwned(purchasedJoker, false);

      widget.onBuy?.call(remainingMoney);
    });

    // Listerner for a bought voucher
    wsClient.addEventListener("voucher_purchased", (data) {
      int itemId = data["item_id"];
      int voucherId = data["voucher_id"];
      int remainingMoney = data["remaining_money"];
      PurchasableItemInfo purchasedJoker = PurchasableItemInfo(
        price: 0,
        id: itemId,
        index: -1,
        type: "owned consumable",
        subtype: voucherId,
        cardName: "",
      );

      widget.consumableCardsKey.currentState?.addConsumableOwned(
        purchasedJoker,
        false,
      );

      widget.onBuy?.call(remainingMoney);
    });

    // Listerner for a sold joker
    wsClient.addEventListener("joker_sold", (data) {
      int remainingMoney = data["remaining_money"];
      widget.onSell?.call(remainingMoney);
    });
  }

  Future<void> onDroppedItem() async {
    setState(() {
      buyWidgetVisible = false;
    });
  }

  Future<void> onDraggedSellItem() async {
    setState(() {
      sellWidgetVisible = true;
    });
  }

  Future<void> onDropSellItem() async {
    setState(() {
      sellWidgetVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShopWidget(
          key: widget.shopWidgetKey,
          buyWidgetKey: widget.buyWidgetKey,
          ownedJokersWidgetKey: widget.jokerCardsKey,
          onDraggedItem: onDraggedItem,
          onDroppedItem: onDroppedItem,
          onReroll: widget.onReroll,
          shopJokers: widget.shopJokers,
          shopConsumables: widget.shopConsumables
        ),
        Visibility(
          visible: buyWidgetVisible,
          child: BuyWidget(
            key: widget.buyWidgetKey,
            shopWidgetKey: widget.shopWidgetKey,
            jokerCardsKey: widget.jokerCardsKey,
            consumableCardsKey: widget.consumableCardsKey,
            onBuy: widget.onBuy,
            gold: widget.gold,
          ),
        ),
        Visibility(
          visible: sellWidgetVisible,
          child: SellWidget(
            key: widget.sellWidgetKey,
            jokerCardsKey: widget.jokerCardsKey,
            consumableCardsKey: widget.consumableCardsKey,
            onSell: widget.onSell,
          ),
        ),
      ],
    );
  }
}
