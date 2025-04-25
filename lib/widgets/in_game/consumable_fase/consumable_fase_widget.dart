import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/consumable_fase/use_consumable_widget.dart';

class ConsumableFaseWidget extends StatefulWidget {
  const ConsumableFaseWidget({
    super.key,
    required this.consumableCardsKey,
    required this.lobbyUsers,
  });

  final GlobalKey<ConsumableCardsState> consumableCardsKey;
  final List<Map<String, dynamic>> lobbyUsers;

  @override
  ConsumableFaseWidgetState createState() => ConsumableFaseWidgetState();
}

class ConsumableFaseWidgetState extends State<ConsumableFaseWidget> {
  final GlobalKey<UseConsumableWidgetState> _useconsumableWidgetKey =
      GlobalKey<UseConsumableWidgetState>();

  bool useConsumableWidgetVisible = false;

  Future<void> onDraggedConsumable() async {
    setState(() {
      useConsumableWidgetVisible = true;
    });
  }

  Future<void> onDroppedConsumable() async {
    setState(() {
      useConsumableWidgetVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Hide the use widget if there's no consumable dragged
        !useConsumableWidgetVisible
            ? SizedBox(height: 100)
            : Visibility(
              visible: useConsumableWidgetVisible,
              child: UseConsumableWidget(
                consumableCardsKey: widget.consumableCardsKey,
                lobbyUsers: widget.lobbyUsers,
                ownKey: _useconsumableWidgetKey,
              ),
            ),

        // Space between
        SizedBox(height: 5),
        // TODO interaccion cartas con consumibles si es que lo hacemos
        
        // Space between
        SizedBox(height: 5),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFd41976),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                16,
              ), // Smooth the border shape
            ),
            minimumSize: const Size(50, 50),
          ),
          child: const Text(" Next Round"),
        ),
      ],
    );
  }
}
