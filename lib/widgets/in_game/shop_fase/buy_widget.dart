import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';

class BuyWidget extends StatelessWidget {
  const BuyWidget({
    super.key,
    required this.onJokerDropped,
    required this.onConsumableDropped,
    required this.onPackageDropped,
  });

  // Callback to inform the joker has been bought
  final Future<void>? Function(int) onJokerDropped;
  final Future<void>? Function(int) onConsumableDropped;
  final Future<void>? Function(int) onPackageDropped;

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
      child: DragTarget<PurchasableItemInfo>(
        onAcceptWithDetails: (DragTargetDetails<PurchasableItemInfo> dragged) {
          switch (dragged.data.type) {
            case "joker":
              onJokerDropped(dragged.data.index);
              break;
            case "consumable":
              onConsumableDropped(dragged.data.index);
              break;
            case "package":
              onPackageDropped(dragged.data.index);
              break;
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
