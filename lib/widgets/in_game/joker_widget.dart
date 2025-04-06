import 'package:flutter/material.dart';

/// Class where we save all info about jokers disposed in the s
class PurchasableItemInfo {
  PurchasableItemInfo({
    required this.price,
    required this.id,
    required this.index,
    required this.type,
  });
  final int price;
  final int id;
  int index;
  final String type;
}

/// Implements the UI of a joker given a ... ... ... ... ... ...
class Joker extends StatelessWidget {
  const Joker({super.key, required this.purchasableItemInfo});

  final PurchasableItemInfo purchasableItemInfo;

  @override
  Widget build(BuildContext context) {
    return Draggable<PurchasableItemInfo>(
      data: purchasableItemInfo, // Data of the joker
      feedback: _buildJokerCard(), // Shown when dragging
      childWhenDragging: Opacity(opacity: 0, child: _buildJokerCard()),
      child: _buildJokerCard(),
    );
  }

  Widget _buildJokerCard({double height = 80}) {
    return Container(
      width: 57,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      //TODO, Add images of jokers next
      child: Text(
        purchasableItemInfo.type,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
