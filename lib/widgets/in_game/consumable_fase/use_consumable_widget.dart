import 'package:flutter/material.dart';
import 'package:nogler/dialogs/game_dialogs.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';

class UseConsumableWidget extends StatefulWidget {
  const UseConsumableWidget({
    super.key,
    required this.consumableCardsKey,
    required this.lobbyUsers,
    required this.ownKey,
  });

  final GlobalKey<OwnedConsumableCardsState> consumableCardsKey;
  final GlobalKey<UseConsumableWidgetState> ownKey;
  final List<Map<String, dynamic>> lobbyUsers;

  @override
  UseConsumableWidgetState createState() => UseConsumableWidgetState();
}

class UseConsumableWidgetState extends State<UseConsumableWidget> {
  final List<Map<String, dynamic>> _lobbyUsers = [
    {'username': "hola", 'avatarImage': 1},
    {'username': "adios", 'avatarImage': 3},
    {'username': "borge", 'avatarImage': 6},
    {'username': "victor", 'avatarImage': 4},
    {'username': "nico", 'avatarImage': 5},
    {'username': "jotemi", 'avatarImage': 1},
    {'username': "jotemi", 'avatarImage': 1},
    {'username': "jotemi", 'avatarImage': 1},
  ];

  // Initialized because the compiler is mad
  PurchasableItemInfo draggedItem = PurchasableItemInfo(
    price: 0,
    id: -1,
    index: -1,
    type: "",
    subtype: 0,
    cardName: "",
  );

  // Get the info of dragged item
  Future<void> setDraggedItem(PurchasableItemInfo currentDragged) async {
    setState(() {
      draggedItem = currentDragged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white),
      ),
      // Make the container receive draggable cards
      child: DragTarget<PurchasableItemInfo>(
        onAcceptWithDetails: (DragTargetDetails<PurchasableItemInfo> dragged) {
          switch (dragged.data.type) {
            case "owned consumable":
              showUseConsumableDialog(
                context,
                dragged.data,
                widget.ownKey,
                _lobbyUsers,
              );
              /*
              // Delete consumable from the owned consumables list
              widget.consumableCardsKey.currentState?.removeConsumableOwned(
                dragged.data,
              );
              */
              break;
          }
        },
        builder: (
          BuildContext context,
          List<dynamic> accepted,
          List<dynamic> rejected,
        ) {
          // Use text widget
          return Center(
            child: Text(
              "Use",
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
