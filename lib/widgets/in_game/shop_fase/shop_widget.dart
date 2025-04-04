import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';

class ShopWidget extends StatefulWidget {
  const ShopWidget({super.key});

  @override
  State<ShopWidget> createState() => _ShopWidgetState();
}

class _ShopWidgetState extends State<ShopWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
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
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _cardBox("\$7", "JOKER"),
                    const SizedBox(width: 5),
                    _cardBox("\$1", "CARD 2"),
                    const SizedBox(width: 5),
                    _cardBox("\$1", "CARD 2"),
                    const SizedBox(width: 5),
                    _cardBox("\$7", "JOKER"),
                  ],
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
                    _cardBox("\$10", "VOUCHER", height: 80),
                    SizedBox(width: 5),
                    _cardBox("\$10", "VOUCHER", height: 80),
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
                      _cardBox("\$4", "BUFFOON"),
                      const SizedBox(width: 5),
                      _cardBox("\$6", "CELESTIAL"),
                      const SizedBox(width: 5),
                      _cardBox("\$6", "CELESTIAL"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cardBox(String price, String label, {double height = 80}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            price,
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        //const SizedBox(height: 2),
        Joker(),
      ],
    );
  }
}
