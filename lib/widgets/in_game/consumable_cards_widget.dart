import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';

/// A widget that displays a row of Joker cards.
/// The number of cards is generated dynamically and displayed below.
class ConsumableCards extends StatefulWidget {
  const ConsumableCards({
    super.key,
    required this.shopWidgetKey,
    required this.buyWidgetKey,
  });

  final GlobalKey<ShopWidgetState> shopWidgetKey;
  final GlobalKey<BuyWidgetState> buyWidgetKey;

  @override
  ConsumableCardsState createState() => ConsumableCardsState();
}

class ConsumableCardsState extends State<ConsumableCards> {
  // List of Joker cards to be displayed
  List<PurchasableItemInfo> consumableOwned = [];

  /// This function checks if the list is full (5 elements)
  /// if it isn't, we add the consumable to the list and remove it from the shop
  /// if it is we do nothing
  ///   this function is called from "buy_widget"
  //TODO, comprobar dinero tambien del usuario
  Future<void> addConsumableOwned(PurchasableItemInfo jokerInfo) async {
    setState(() {
      if (consumableOwned.length != 5) {
        // Remove the bought consumable
        widget.shopWidgetKey.currentState?.removeConsumable(jokerInfo.index);
        // Add it to your owned list
        final PurchasableItemInfo auxJokerInfo = PurchasableItemInfo(
          price: jokerInfo.price,
          id: jokerInfo.id,
          index: -1, // Not used
          type: "owned consumable",
        );
        consumableOwned.add(auxJokerInfo);
        debugPrint("Consumible añadido en la lista");
      } else {
        debugPrint("La lista de consumibles esta llena");
      }
    });
  }

  //TODO, placeholder del backend de momento
  void _generateRandomConsumable() {
    final random = Random();
    consumableOwned = List.generate(2, (int index) {
      return PurchasableItemInfo(
        price: random.nextInt(10),
        id: index,
        index: -1,
        type: "owned consumable",
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _generateRandomConsumable();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Displays the label for active consumables.
            Text(
              "Active consumables",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),

            // Displays the count of Consumable cards.
            Text(
              "${consumableOwned.length} / 5",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        // Displays the row of Consumable cards.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(consumableOwned.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: Joker(
                  purchasableItemInfo: consumableOwned[index],
                  // Display sell widget
                  onDraggedItem: () {
                    return null;
                  },
                  // Hide sell widget
                  onDroppedItem: () {
                    return null;
                  },
                  buyWidgetKey: widget.buyWidgetKey,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
