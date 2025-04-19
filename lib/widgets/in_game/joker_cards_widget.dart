//import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/sell_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_fase_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';

/// A widget that displays a row of Joker cards.
/// The number of cards is generated dynamically and displayed below.
class JokerCards extends StatefulWidget {
  const JokerCards({
    super.key,
    required this.shopWidgetKey,
    required this.buyWidgetKey,
    required this.shopFaseWidgetKey,
    required this.sellWidgetKey,
  });

  final GlobalKey<ShopWidgetState> shopWidgetKey;
  final GlobalKey<BuyWidgetState> buyWidgetKey;
  final GlobalKey<ShopFaseWidgetState> shopFaseWidgetKey;
  final GlobalKey<SellWidgetState> sellWidgetKey;

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
  Future<void> addJokerOwned(
    PurchasableItemInfo jokerInfo,
    bool isPackage,
  ) async {
    setState(() {
      if (jokersOwned.length != 5) {
        // Remove the bought joker
        widget.shopWidgetKey.currentState?.removeJoker(
          jokerInfo.index,
          isPackage,
        );
        // Add it to your owned list
        final PurchasableItemInfo auxJokerInfo = PurchasableItemInfo(
          price: jokerInfo.price,
          id: jokerInfo.id,
          index: -1, // Not used
          type: "owned joker",
          subtype: jokerInfo.subtype,
        );
        jokersOwned.add(auxJokerInfo);
        _updateIndex();
        debugPrint(
          "Joker añadido en la lista con el precio: ${jokerInfo.price}",
        );
      } else {
        debugPrint("La lista esta llena");
      }
    });
  }

  /// This function removes the joker from the owned list
  Future<void> removeJokerOwned(PurchasableItemInfo jokerInfo) async {
    setState(() {
      if (jokersOwned.isNotEmpty) {
        // Remove the joker from the owned list
        jokersOwned.remove(jokerInfo);
        _updateIndex();
        debugPrint("Joker eliminado de la lista");
      } else {
        debugPrint("La lista esta vacia");
      }
    });
  }

  void _generateRandomJoker() {
    final random = Random();
    jokersOwned = List.generate(1, (int index) {
      return PurchasableItemInfo(
        price: random.nextInt(10),
        id: index,
        index: index,
        type: "owned joker",
        subtype: "SolidSeven",
      );
    });
  }

  void _updateIndex() {
    for (int i = 0; i < jokersOwned.length; i++) {
      jokersOwned[i].index = i;
    }
  }

  @override
  void initState() {
    super.initState();
    _generateRandomJoker();
    _updateIndex();
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
          children:
              jokersOwned.isEmpty
                  ? [SizedBox(height: 75)]
                  : List.generate(jokersOwned.length, (index) {
                    return DragTarget<PurchasableItemInfo>(
                      // Update the list as we move the joker in it
                      onAcceptWithDetails: (details) {
                        final fromIndex = details.data;
                        // Calculate the difference of the stride
                        //    if difference > 0 == moving joker to the right
                        //    if difference < 0 == moving joker to the left
                        int difference = index - fromIndex.index;
                        // save it for later
                        final draggedJoker = jokersOwned[fromIndex.index];
                        setState(() {
                          switch (difference) {
                            //    if difference < 0 == moving joker to the left
                            case < 0:
                              for (
                                int i = fromIndex.index - 1;
                                i >= index;
                                i--
                              ) {
                                jokersOwned[i + 1] = jokersOwned[i];
                              }
                              jokersOwned[index] = draggedJoker;
                              break;
                            //    if difference > 0 == moving joker to the right
                            case > 0:
                              for (int i = fromIndex.index; i < index; i++) {
                                jokersOwned[i] = jokersOwned[i + 1];
                              }
                              jokersOwned[index] = draggedJoker;
                              break;
                            // if difference = 0 == same spot
                            default:
                              break;
                          }
                          // update the indexes of the jokers
                          _updateIndex();
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: Joker(
                            keyWidget: widget.sellWidgetKey,
                            purchasableItemInfo: jokersOwned[index],
                            // Display sell widget
                            onDraggedItem: () {
                              widget.shopFaseWidgetKey.currentState
                                  ?.onDraggedSellItem();
                              return;
                            },
                            // Hide sell widget
                            onDroppedItem: () {
                              widget.shopFaseWidgetKey.currentState
                                  ?.onDropSellItem();
                              return;
                            },
                          ),
                        );
                      },
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
