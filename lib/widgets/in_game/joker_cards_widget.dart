import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/card_widget.dart';
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
    required this.jokersOwned,
    required this.onScore,
  });

  final GlobalKey<ShopWidgetState> shopWidgetKey;
  final GlobalKey<BuyWidgetState> buyWidgetKey;
  final GlobalKey<ShopFaseWidgetState> shopFaseWidgetKey;
  final GlobalKey<SellWidgetState> sellWidgetKey;
  final List<PurchasableItemInfo> jokersOwned;
  final void Function(int) onScore;

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
  Future<void> addJokerOwned(
    PurchasableItemInfo jokerInfo,
    bool isPackage,
  ) async {
    setState(() {
      if (jokersOwned.length != 5) {
        // Add it to your owned list
        final PurchasableItemInfo auxJokerInfo = PurchasableItemInfo(
          price: jokerInfo.price,
          id: jokerInfo.id,
          index: -1, // Not used
          type: "owned joker",
          subtype: jokerInfo.subtype,
          rank: '',
          suit: '',
          overlay: 0,
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

  Future<void> triggerJokers(
    bool lastCard,
    SelectableCard currentCardPlayed,
    List<bool> jokersTriggered,
  ) async {
    int showJoker = 200;
    // Trigger the joker effects after cards are played
    if (lastCard) {
      for (int i = 0; i < jokersOwned.length; i++) {
        if (jokersTriggered[i]) {
          await Future.delayed(Duration(milliseconds: showJoker), () {
            widget.onScore(i);
          });
          // After 400 ms we hide the onScore message

          await Future.delayed(Duration(milliseconds: showJoker), () {
            widget.onScore(i);
          });
        }
      }
    }
    // Trigger the joker effects when a card is played
    else {
      for (int i = 0; i < jokersOwned.length; i++) {
        final joker = jokersOwned[i];
        if (jokersTriggered[i]) {
          switch (joker.subtype) {
            // BIRDIFICACION joker
            case 8:
              List<String> myList = ['1', '4', '6', '7'];
              if (myList.contains(currentCardPlayed.score)) {
                await Future.delayed(Duration(milliseconds: showJoker), () {
                  widget.onScore(i);
                });
                await Future.delayed(Duration(milliseconds: showJoker), () {
                  widget.onScore(i);
                });
              }
              break;
            // Lirili Larila
            case 11:
              if (currentCardPlayed.score == "2") {
                await Future.delayed(Duration(milliseconds: showJoker), () {
                  widget.onScore(i);
                });
                await Future.delayed(Duration(milliseconds: showJoker), () {
                  widget.onScore(i);
                });
              }
              break;
            // Crowave joker
            case 14:
              if (currentCardPlayed.suit == "d" ||
                  currentCardPlayed.suit == "h") {
                await Future.delayed(Duration(milliseconds: showJoker), () {
                  widget.onScore(i);
                });
                await Future.delayed(Duration(milliseconds: showJoker), () {
                  widget.onScore(i);
                });
              }
              break;
            // Bicycle
            case 15:
              if (currentCardPlayed.score == "2") {
                await Future.delayed(Duration(milliseconds: showJoker), () {
                  widget.onScore(i);
                });
                await Future.delayed(Duration(milliseconds: showJoker), () {
                  widget.onScore(i);
                });
              }
              break;
          }
        }
      }
    }
  }

  void _updateIndex() {
    for (int i = 0; i < jokersOwned.length; i++) {
      jokersOwned[i].index = i;
    }
  }

  @override
  void initState() {
    super.initState();
    jokersOwned = widget.jokersOwned;
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
                  ? [SizedBox(height: 68)]
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
                          margin: const EdgeInsets.symmetric(horizontal: 6),
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
