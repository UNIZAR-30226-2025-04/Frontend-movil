import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_cards_widget.dart';
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
  });

  final GlobalKey<ShopWidgetState> shopWidgetKey;
  final GlobalKey<JokerCardsState> jokerCardsKey;
  final GlobalKey<ConsumableCardsState> consumableCardsKey;
  final GlobalKey<BuyWidgetState> buyWidgetKey;
  final GlobalKey<SellWidgetState> sellWidgetKey;

  @override
  State<ShopFaseWidget> createState() => ShopFaseWidgetState();
}

class ShopFaseWidgetState extends State<ShopFaseWidget> {
  bool buyWidgetVisible = false;
  bool sellWidgetVisible = false;
  Future<void> onDraggedItem() async {
    setState(() {
      buyWidgetVisible = true;
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
        ),
        Visibility(
          visible: buyWidgetVisible,
          child: BuyWidget(
            key: widget.buyWidgetKey,
            shopWidgetKey: widget.shopWidgetKey,
            jokerCardsKey: widget.jokerCardsKey,
            consumableCardsKey: widget.consumableCardsKey,
          ),
        ),
        Visibility(
          visible: sellWidgetVisible,
          child: SellWidget(
            key: widget.sellWidgetKey,
            jokerCardsKey: widget.jokerCardsKey,
            consumableCardsKey: widget.consumableCardsKey,
          ),
        ),
      ],
    );
  }
}
