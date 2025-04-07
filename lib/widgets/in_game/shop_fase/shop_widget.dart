import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/joker_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';

class ShopWidget extends StatefulWidget {
  const ShopWidget({
    super.key,
    required this.buyWidgetKey,
    required this.ownedJokersWidgetKey,
    required this.onDraggedItem,
    required this.onDroppedItem,
  });

  final GlobalKey<BuyWidgetState> buyWidgetKey;
  final GlobalKey<JokerCardsState> ownedJokersWidgetKey;
  final Future<void>? Function() onDraggedItem;
  final Future<void>? Function() onDroppedItem;

  @override
  State<ShopWidget> createState() => ShopWidgetState();
}

class ShopWidgetState extends State<ShopWidget> {
  List<PurchasableItemInfo> shopJokers = [];
  List<PurchasableItemInfo> shopConsumables = [];
  List<PurchasableItemInfo> shopPackages = [];

  // Function used to generate random jokers when we enter shop fase and refresh the shop
  void _generateRandomJoker() {
    final random = Random();
    shopJokers = List.generate(4, (int index) {
      return PurchasableItemInfo(
        price: random.nextInt(10),
        id: index,
        index: -1,
        type: "joker",
      );
    });
  }

  // Function used to generate random consumables when we enter shop fase
  void _generateRandomConsumable() {
    final random = Random();
    shopConsumables = List.generate(2, (int index) {
      return PurchasableItemInfo(
        price: random.nextInt(10),
        id: index,
        index: -1,
        type: "consumable",
      );
    });
  }

  // Function used to generate random packages when we enter shop fase
  void _generateRandomPackage() {
    final random = Random();
    shopPackages = List.generate(3, (int index) {
      return PurchasableItemInfo(
        price: random.nextInt(10),
        id: index,
        index: -1,
        type: "package",
      );
    });
  }

  PurchasableItemInfo updateIndex(PurchasableItemInfo item, int index) {
    item.index = index;
    return item;
  }

  Future<void> removeJoker(int index) async {
    setState(() {
      shopJokers.removeAt(index);
      debugPrint("Eliminado joker tienda en indice $index");
    });
  }

  Future<void> removeConsumable(int index) async {
    setState(() {
      shopConsumables.removeAt(index);
      debugPrint("Eliminado consumible $index");
    });
  }

  Future<void> removePackage(int index) async {
    setState(() {
      shopPackages.removeAt(index);
      debugPrint("Eliminado paquete $index");
    });
  }

  @override
  void initState() {
    super.initState();
    _generateRandomJoker();
    _generateRandomConsumable();
    _generateRandomPackage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      //height: 270,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border.all(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Next round and reroll buttons, buying items
          Row(
            children: [
              Expanded(
                // Porcentage of space used, shared with the list of jokers
                flex: 3,
                child: Column(
                  spacing: 5,
                  children: [
                    // Next Round button
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Smooth the border shape
                        ),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text(" Next\nRound"),
                    ),
                    // Space between
                    const SizedBox(width: 15),

                    // Reroll button
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _generateRandomJoker();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Smooth the border shape
                        ),
                        minimumSize: const Size.fromHeight(55),
                      ),
                      child: const Text(
                        "Reroll\n\$5",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Space Between
              const SizedBox(width: 5),

              // Joker slots
              Expanded(
                // Porcentage of space used, shared with the floating buttons
                flex: 8,
                child: Container(
                  width: 276,
                  height: 119,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    // Display of all purschasable jokers
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(shopJokers.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: _cardAndPrice(
                            updateIndex(shopJokers[index], index),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3),

          // Package and prime consumable slots
          Row(
            children: [
              Container(
                width: 145,
                height: 115,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  // Display of all purschasable consumables
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(shopConsumables.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: _cardAndPrice(
                          updateIndex(shopConsumables[index], index),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  width: 145,
                  height: 115,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    // Display of all purschasable packages
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(shopPackages.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: _cardAndPrice(
                            updateIndex(shopPackages[index], index),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardAndPrice(PurchasableItemInfo info) {
    return Column(
      children: [
        // Display of price
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "\$${info.price}",
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Display joker
        Joker(
          purchasableItemInfo: info,
          onDraggedItem: widget.onDraggedItem,
          onDroppedItem: widget.onDroppedItem,
          buyWidgetKey: widget.buyWidgetKey,
        ),
      ],
    );
  }
}
