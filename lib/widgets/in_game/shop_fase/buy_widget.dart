import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';

class BuyWidget extends StatelessWidget {
  const BuyWidget({
    super.key,
    required this.shopWidgetKey,
    required this.jokerCardsKey,
    required this.consumableCardsKey,
  });

  final GlobalKey<ShopWidgetState> shopWidgetKey;
  final GlobalKey<JokerCardsState> jokerCardsKey;
  final GlobalKey<ConsumableCardsState> consumableCardsKey;

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
            case "joker":
              jokerCardsKey.currentState?.addJokerOwned(dragged.data);
              break;
            case "consumable":
              consumableCardsKey.currentState?.addConsumableOwned(dragged.data);
              break;
            case "package":
              shopWidgetKey.currentState?.removePackage(dragged.data.index);
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
              "Buy\n\$ 17",
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
