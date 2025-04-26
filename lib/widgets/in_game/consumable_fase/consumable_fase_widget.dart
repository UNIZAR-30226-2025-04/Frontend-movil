import 'package:flutter/material.dart';
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
  bool useConsumableWidgetVisible = false;

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
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Hide the use widget if there's no consumable dragged
        !useConsumableWidgetVisible
            ? SizedBox(height: 100)
            : Visibility(
              visible: useConsumableWidgetVisible,
              child: UseConsumableWidget(
                consumableCardsKey: widget.ownedConsumableCardsKey,
                lobbyUsers: widget.lobbyUsers,
                ownKey: widget.useConsumableWidgetKey,
              ),
            ),

        // Space between
        SizedBox(height: 5),
        // TODO interaccion cartas con consumibles si es que lo hacemos
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
          onPressed: () {},
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
