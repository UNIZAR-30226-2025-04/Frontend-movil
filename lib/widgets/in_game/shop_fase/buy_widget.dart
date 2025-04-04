import 'package:flutter/material.dart';

class BuyWidget extends StatelessWidget {
  const BuyWidget({super.key, required this.onJokerDropped});

  // Callback to inform the joker has been bought
  final Future<void>? Function(int) onJokerDropped;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 220,
      margin: const EdgeInsets.fromLTRB(16, 16, 0, 0),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white),
      ),
      child: DragTarget<int>(
        onAcceptWithDetails: (DragTargetDetails<int> dragged) {
          if (dragged.data == 1) {
            debugPrint("Reconocido joker");
            onJokerDropped(dragged.data);
          }
        },
        builder: (
          BuildContext context,
          List<dynamic> accepted,
          List<dynamic> rejected,
        ) {
          // Buy text widget
          return Center(
            child: Text(
              "Buy\n\$ 17",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}
