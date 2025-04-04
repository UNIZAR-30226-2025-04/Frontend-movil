import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';

class ShopWidget extends StatefulWidget {
  const ShopWidget({super.key});

  @override
  State<ShopWidget> createState() => ShopWidgetState();
}

class JokerInfo {
  final int id;

  JokerInfo({required this.id});
}

class ShopWidgetState extends State<ShopWidget> {
  List<JokerInfo> shopJokers = [];

  void _generateRandomJoker() {
    final random = Random();
    shopJokers = List.generate(4, (_) {
      return JokerInfo(id: random.nextInt(10));
    });
  }

  Future<void> removeJoker(int index) async {
    setState(() {
      shopJokers.removeAt(index);
      debugPrint("Eliminado joker $index");
    });
  }

  @override
  void initState() {
    super.initState();
    _generateRandomJoker();
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
                      child: const Text("Next \nRound"),
                    ),
                    // Space between
                    const SizedBox(width: 15),

                    // Reroll button
                    ElevatedButton(
                      onPressed: () {},
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

              // Joker and consumables slots
              Container(
                width: 276,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(shopJokers.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: _cardBox(shopJokers[index].id, index, "joker"),
                      );
                    }),
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
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      _cardBox(10, 0, "VOUCHER", height: 80),
                      SizedBox(width: 5),
                      _cardBox(10, 0, "VOUCHER", height: 80),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _cardBox(4, 0, "BUFFOON"),
                        const SizedBox(width: 5),
                        _cardBox(6, 0, "CELESTIAL"),
                        const SizedBox(width: 5),
                        _cardBox(6, 0, "CELESTIAL"),
                      ],
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

  Widget _cardBox(int price, int index, String label, {double height = 80}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            price.toString(),
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        //const SizedBox(height: 2),
        Joker(index: index),
      ],
    );
  }
}
