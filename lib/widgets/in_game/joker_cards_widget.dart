import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';

/// A widget that displays a row of Joker cards.
/// The number of cards is generated dynamically and displayed below.
class JokerCards extends StatefulWidget {
  const JokerCards({super.key});

  @override
  JokerCardsState createState() => JokerCardsState();
}

class JokerCardsState extends State<JokerCards> {
  // List of Joker cards to be displayed
  List<PurchasableItemInfo> jokersOwned = [];

  Future<void> addJokerOwned(PurchasableItemInfo jokerInfo) async {
    debugPrint("Joker añadido en ");
    setState(() {
      jokersOwned.add(jokerInfo);
      debugPrint("Joker añadido en ");
    });
  }

  void _generateRandomJoker() {
    final random = Random();
    jokersOwned = List.generate(4, (int index) {
      return PurchasableItemInfo(
        price: random.nextInt(10),
        id: index,
        index: -1,
        type: "joker",
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
              child: Joker(purchasableItemInfo: jokersOwned[index]),
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
