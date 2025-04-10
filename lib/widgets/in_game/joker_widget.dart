import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/sell_widget.dart';

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

class Joker extends StatefulWidget {
  const Joker({
    super.key,
    required this.purchasableItemInfo,
    required this.onDraggedItem,
    required this.onDroppedItem,
    required this.keyWidget,
  });

  final PurchasableItemInfo purchasableItemInfo;
  final Future<void>? Function() onDraggedItem;
  final Future<void>? Function() onDroppedItem;
  final GlobalKey<State<StatefulWidget>> keyWidget;

  @override
  JokerState createState() => JokerState();
}

/// Implements the UI of a joker given a ... ... ... ... ... ...
class JokerState extends State<Joker> {
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    return Draggable<PurchasableItemInfo>(
      data: widget.purchasableItemInfo, // Data of the joker
      feedback: _buildJokerCard(), // Shown when dragging
      childWhenDragging: Opacity(opacity: 0, child: _buildJokerCard()),

      onDragUpdate: (details) {
        widget.onDraggedItem();
        final state = widget.keyWidget.currentState;
        if (state is BuyWidgetState) {
          state.setDraggedItem(widget.purchasableItemInfo);
        } else if (state is SellWidgetState) {
          state.setDraggedItem(widget.purchasableItemInfo);
        }
      },

      onDragEnd: (details) {
        widget.onDroppedItem();
      },
      child: Builder(
        builder:
            (jokerContext) => GestureDetector(
              onLongPress: () {
                final renderBox = jokerContext.findRenderObject() as RenderBox;
                final size = renderBox.size;
                final position = renderBox.localToGlobal(Offset(size.width, 0));
                _showJokerDescription(widget.purchasableItemInfo, position);
              },
              onLongPressEnd: (_) => _hideJokerDescription(),
              child: _buildJokerCard(),
            ),
      ),
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
      child:
          // Consumables images
          (widget.purchasableItemInfo.type == "consumable" ||
                  widget.purchasableItemInfo.type == "owned consumable")
              ? consumablesMap[widget.purchasableItemInfo.id]['consumable']! !=
                      "no consumable"
                  ? Image.asset(
                    consumablesMap[widget
                        .purchasableItemInfo
                        .id]['consumable']!,
                    fit: BoxFit.cover,
                  )
                  // Replace in case it doenst have image
                  : Text(
                    "${widget.purchasableItemInfo.type} ${widget.purchasableItemInfo.id}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  )
              // Jokers images
              : (widget.purchasableItemInfo.type == "joker" ||
                  widget.purchasableItemInfo.type == "owned joker")
              ? jokersMap[widget.purchasableItemInfo.id]['joker'] != "no joker"
                  ? Image.asset(
                    jokersMap[widget.purchasableItemInfo.id]['joker']!,
                    //fit: BoxFit.fitWidth,
                  )
                  // Replace in case it doenst have image
                  : Text(
                    "${widget.purchasableItemInfo.type} ${widget.purchasableItemInfo.id}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  )
              // Replace in case it doenst have image
              : Text(
                "${widget.purchasableItemInfo.type} ${widget.purchasableItemInfo.id}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
    );
  }

  void _showJokerDescription(PurchasableItemInfo purchasable, Offset position) {
    _overlayEntry?.remove();

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Builder(
          builder: (ctx) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final renderBox = ctx.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final height = renderBox.size.height;

                // Resize the description just a bit above the card
                _overlayEntry?.remove();
                _overlayEntry = OverlayEntry(
                  builder:
                      (_) => Positioned(
                        left: position.dx - 87,
                        top:
                            purchasable.type == "owned joker" ||
                                    purchasable.type == "owned consumable"
                                ? position.dy + height + 10
                                : position.dy - height - 20,
                        width: 120,
                        child: Material(
                          color: Colors.transparent,
                          child: _buildDescription(purchasable),
                        ),
                      ),
                );
                Overlay.of(ctx).insert(_overlayEntry!);
              }
            });

            // Provisional position for the description
            return Positioned(
              top: -9999,
              left: -9999,
              child: Material(
                color: Colors.transparent,
                child: _buildDescription(purchasable),
              ),
            );
          },
        );
      },
    );

    _overlayEntry = entry;
    Overlay.of(context).insert(entry);
  }

  void _hideJokerDescription() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildDescription(PurchasableItemInfo purchasable) {
    return Container(
      //width: 100,
      //height ?
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Container to show the card played
          Text(
            jokersMap[purchasable.id]['jokerName']!,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // Container to show the chips gained and aditional effects triggered when the card is played
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade700, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Container(
              // Container to add some margin
              margin: const EdgeInsets.all(4),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: jokersMap[purchasable.id]['jokerDescription'],
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              border: Border.all(color: Colors.grey.shade700, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              child: Text(
                "Rare",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<Map<String, String>> consumablesMap = [
  {
    // No consumable
    'consumable': 'no consumable',
    'consumableName': '',
    'consumableDescription': '',
  },
  {
    // 1. Death consumable
    'consumable': 'images/consumables/death.png',
    'consumableName': 'no consumable',
    'consumableDescription': '',
  },
  {
    // No consumable
    'consumable': 'no consumable',
    'consumableName': '',
    'consumableDescription': '',
  },
  {
    // No consumable
    'consumable': 'no consumable',
    'consumableName': '',
    'consumableDescription': '',
  },
  {
    // No consumable
    'consumable': 'no consumable',
    'consumableName': '',
    'consumableDescription': '',
  },
];

List<Map<String, String>> jokersMap = [
  {
    // No joker
    'joker': 'no joker',
    'jokerName': '',
    'jokerDescription': '',
  },
  {
    // 1. Solid seven joker
    'joker': 'images/jokers/solid_seven.png',
    'jokerName': 'Solid Seven',
    'jokerDescription': '',
  },
  {
    // No joker
    'joker': 'no joker',
    'jokerName': '',
    'jokerDescription': '',
  },
  {
    // No joker
    'joker': 'no joker',
    'jokerName': '',
    'jokerDescription': '',
  },
  {
    // No joker
    'joker': 'no joker',
    'jokerName': '',
    'jokerDescription': '',
  },
];
