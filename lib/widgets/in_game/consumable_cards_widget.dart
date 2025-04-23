import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/consumable_fase/consumable_fase_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/sell_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_fase_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';

/// A widget that displays a row of Joker cards.
/// The number of cards is generated dynamically and displayed below.
class ConsumableCards extends StatefulWidget {
  const ConsumableCards({
    super.key,
    required this.shopFaseWidgetKey,
    required this.consumableFaseWidgetKey,
    required this.shopWidgetKey,
    required this.buyWidgetKey,
    required this.sellWidgetKey,
  });

  final GlobalKey<ShopFaseWidgetState> shopFaseWidgetKey;
  final GlobalKey<ConsumableFaseWidgetState> consumableFaseWidgetKey;
  final GlobalKey<ShopWidgetState> shopWidgetKey;
  final GlobalKey<BuyWidgetState> buyWidgetKey;
  final GlobalKey<SellWidgetState> sellWidgetKey;

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
  Future<void> addConsumableOwned(
    PurchasableItemInfo jokerInfo,
    bool isPackage,
  ) async {
    setState(() {
      if (consumableOwned.length != 5) {
        // Remove the bought consumable
        widget.shopWidgetKey.currentState?.removeConsumable(
          jokerInfo.index,
          isPackage,
        );
        // Add it to your owned list
        final PurchasableItemInfo auxJokerInfo = PurchasableItemInfo(
          price: jokerInfo.price,
          id: jokerInfo.id,
          index: -1, // Not used
          type: "owned consumable",
          subtype: jokerInfo.subtype,
        );
        consumableOwned.add(auxJokerInfo);
        debugPrint("Consumible añadido en la lista");
      } else {
        debugPrint("La lista de consumibles esta llena");
      }
    });
  }

  /// This function removes the consumable from the owned list
  Future<void> removeConsumableOwned(PurchasableItemInfo jokerInfo) async {
    setState(() {
      if (consumableOwned.isNotEmpty) {
        // Remove the consumable from the owned list
        consumableOwned.remove(jokerInfo);
        debugPrint("Consumible eliminado de la lista");
      } else {
        debugPrint("No hay consumibles para eliminar");
      }
    });
  }

  // Function used to generate random consumables when we enter game fase
  void _generateRandomConsumable() {
    final random = Random();
    const subtypes = ["ClearanceSale", "death", "CrystalBall"];
    consumableOwned = List.generate(2, (int index) {
      final randomSubtype = subtypes[random.nextInt(subtypes.length)];
      return PurchasableItemInfo(
        price: random.nextInt(10),
        id: index,
        index: -1,
        type: "owned consumable",
        subtype: randomSubtype,
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
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            // Displays the count of Consumable cards.
            Text(
              "${consumableOwned.length} / 5",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        // Displays the row of Consumable cards.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                consumableOwned.isEmpty
                    ? [SizedBox(height: 75)]
                    : List.generate(consumableOwned.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Joker(
                          purchasableItemInfo: consumableOwned[index],
                          // Display sell widget
                          onDraggedItem: () {
                            widget.shopFaseWidgetKey.currentState
                                ?.onDraggedSellItem();
                            widget.consumableFaseWidgetKey.currentState
                                ?.onDraggedConsumable();
                            return;
                          },
                          // Hide sell widget
                          onDroppedItem: () {
                            widget.shopFaseWidgetKey.currentState
                                ?.onDropSellItem();
                            widget.consumableFaseWidgetKey.currentState
                                ?.onDroppedConsumable();
                            return;
                          },
                          keyWidget: widget.sellWidgetKey,
                        ),
                      );
                    }),
          ),
        ),
      ],
    );
  }
}
