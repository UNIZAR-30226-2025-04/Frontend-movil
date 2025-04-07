import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';

//TODO, moverlo a otra pantalla
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
  const Joker({
    super.key,
    required this.purchasableItemInfo,
    required this.onDraggedItem,
    required this.onDroppedItem,
    required this.buyWidgetKey,
  });

  final PurchasableItemInfo purchasableItemInfo;
  final Future<void>? Function() onDraggedItem;
  final Future<void>? Function() onDroppedItem;
  final GlobalKey<BuyWidgetState> buyWidgetKey;

  VoidCallback? prueba() {
    debugPrint("Dragged started");
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<PurchasableItemInfo>(
      data: purchasableItemInfo, // Data of the joker
      feedback: _buildJokerCard(), // Shown when dragging
      childWhenDragging: Opacity(opacity: 0, child: _buildJokerCard()),
      //onDragStarted: onDraggedItem(),
      onDragUpdate: (details) {
        onDraggedItem();
        buyWidgetKey.currentState?.setDraggedItem(purchasableItemInfo);
      },
      //onDragCompleted: onDroppedItem(),
      onDragEnd: (details) {
        onDroppedItem();
      },
      child: _buildJokerCard(),
    );
  }

  Widget _buildJokerCard({double height = 75}) {
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
        "${purchasableItemInfo.type} ${purchasableItemInfo.id}",
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
