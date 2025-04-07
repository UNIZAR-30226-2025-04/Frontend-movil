import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';

/// A widget that displays a row of Joker cards.
/// The number of cards is generated dynamically and displayed below.
class JokerCards extends StatefulWidget {
  const JokerCards({
    super.key,
    required this.shopWidgetKey,
    required this.buyWidgetKey,
  });

  final GlobalKey<ShopWidgetState> shopWidgetKey;
  final GlobalKey<BuyWidgetState> buyWidgetKey;

  @override
  JokerCardsState createState() => JokerCardsState();
}

class JokerCardsState extends State<JokerCards> {
  // List of Joker cards to be displayed
  List<PurchasableItemInfo> jokersOwned = [];

  /// This function checks if the list is full (5 elements)
  /// if it isn't, we add the joker to the list and remove it from the shop
  /// if it is we do nothing
  ///   this function is called from "buy_widget"
  //TODO, comprobar dinero tambien del usuario
  Future<void> addJokerOwned(PurchasableItemInfo jokerInfo) async {
    setState(() {
      if (jokersOwned.length != 5) {
        // Remove the bought joker
        widget.shopWidgetKey.currentState?.removeJoker(jokerInfo.index);
        // Add it to your owned list
        final PurchasableItemInfo auxJokerInfo = PurchasableItemInfo(
          price: jokerInfo.price,
          id: jokerInfo.id,
          index: -1, // Not used
          type: "owned joker",
        );
        jokersOwned.add(auxJokerInfo);
        debugPrint("Joker añadido en la lista");
      } else {
        debugPrint("La lista esta llena");
      }
    });
  }

  void _generateRandomJoker() {
    final random = Random();
    jokersOwned = List.generate(4, (int index) {
      return PurchasableItemInfo(
        price: random.nextInt(10),
        id: index,
        index: -1,
        type: "owned joker",
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _generateRandomJoker();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Displays the row of Joker cards.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(jokersOwned.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Joker(
                buyWidgetKey: widget.buyWidgetKey,
                purchasableItemInfo: jokersOwned[index],
                // Display sell widget
                onDraggedItem: () {
                  return null;
                },
                // Hide sell widget
                onDroppedItem: () {
                  return null;
                },
              ),
            );
          }),
        ),

        // Displays the count of Joker cards.
        Text(
          "${jokersOwned.length} / 5",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
