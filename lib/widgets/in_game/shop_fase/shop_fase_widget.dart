import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/joker_cards_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';

class ShopFaseWidget extends StatefulWidget {
  const ShopFaseWidget({
    super.key,
    required this.jokerCards,
    required this.shopWidgetKey,
  });

  final GlobalKey<JokerCardsState> jokerCards;
  final GlobalKey<ShopWidgetState> shopWidgetKey;

  @override
  State<ShopFaseWidget> createState() => ShopFaseWidgetState();
}

class ShopFaseWidgetState extends State<ShopFaseWidget> {
  bool buyWidgetVisible = false;

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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          ShopWidget(
            key: widget.shopWidgetKey,
            ownedJokersWidgetKey: widget.jokerCards,
            onDraggedItem: onDraggedItem,
            onDroppedItem: onDroppedItem,
          ),
          Visibility(
            visible: buyWidgetVisible,
            child: BuyWidget(
              shopWidgetKey: widget.shopWidgetKey,
              jokerCardsKey: widget.jokerCards,
            ),
          ),
        ],
      ),
    );
  }
}
