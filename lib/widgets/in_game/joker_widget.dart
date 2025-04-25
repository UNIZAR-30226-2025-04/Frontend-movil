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
    required this.subtype,
    required this.cardName,
  });
  final int price;
  final int id;
  int index;
  final String type;
  // TODO, add a description of the joker
  final int subtype;
  String cardName = "";
}

class Joker extends StatefulWidget {
  const Joker({
    super.key,
    required this.purchasableItemInfo,
    this.onDraggedItem,
    this.onDroppedItem,
    required this.keyWidget,
  });

  final PurchasableItemInfo purchasableItemInfo;
  final Future<void>? Function()? onDraggedItem;
  final Future<void>? Function()? onDroppedItem;
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
        if (widget.onDraggedItem != null) {
          widget.onDraggedItem!();
        }
        final state = widget.keyWidget.currentState;
        if (state is BuyWidgetState) {
          state.setDraggedItem(widget.purchasableItemInfo);
        } else if (state is SellWidgetState) {
          state.setDraggedItem(widget.purchasableItemInfo);
        }
      },

      onDragEnd: (details) {
        if (widget.onDroppedItem != null) {
          widget.onDroppedItem!();
        }
      },
      child: Builder(
        builder:
            (jokerContext) => GestureDetector(
              onLongPress: () {
                final renderBox = jokerContext.findRenderObject() as RenderBox;
                final size = renderBox.size;
                final position = renderBox.localToGlobal(Offset(size.width, 0));
                _showItemDescription(widget.purchasableItemInfo, position);
              },
              onLongPressEnd: (_) => _hideJokerDescription(),
              child: _buildJokerCard(),
            ),
      ),
    );
  }

  Widget _buildJokerCard({double height = 68}) {
    return Container(
      width: 57,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.transparent),
      ),

      child:
          // Consumables images
          (widget.purchasableItemInfo.type == "consumable" ||
                  widget.purchasableItemInfo.type == "owned consumable")
              ? Image.asset(
                getConsumableImageBySubtype(widget.purchasableItemInfo.subtype),
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    "${widget.purchasableItemInfo.type} ${widget.purchasableItemInfo.id}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              )
              : (widget.purchasableItemInfo.type == "joker" ||
                  widget.purchasableItemInfo.type == "owned joker")
              ? Image.asset(
                getJokerImageBySubtype(widget.purchasableItemInfo.subtype),
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    "${widget.purchasableItemInfo.type} ${widget.purchasableItemInfo.id}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              )
              : (widget.purchasableItemInfo.type == "package")
              ? Image.asset(
                getPackageImageBySubtype(widget.purchasableItemInfo.subtype),
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    "${widget.purchasableItemInfo.type} ${widget.purchasableItemInfo.id}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              )
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

  void _showItemDescription(PurchasableItemInfo purchasable, Offset position) {
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
    String? name;
    String? description;

    int index = purchasable.subtype;
    switch (purchasable.type.replaceAll('owned ', '')) {
      case 'joker':
        if (index >= 0 && index < jokersMap.length) {
          final item = jokersMap[index];
          name = item['jokerName'];
          description = item['jokerDescription'];
        }
        break;
      case 'consumable':
        if (index >= 0 && index < consumablesMap.length) {
          final item = consumablesMap[index];
          name = item['consumableName'];
          description = item['consumableDescription'];
        }
        break;
      case 'package':
        if (index >= 0 && index < packagesMap.length) {
          final item = packagesMap[index];
          name = item['packageName'];
          description = item['packageDescription'];
        }
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (name != null)
            Text(
              name,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          if (description != null && description.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade700, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              margin: const EdgeInsets.only(top: 4),
              child: Container(
                margin: const EdgeInsets.all(4),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // List of consumables with their image path, internal name, and description
  List<Map<String, String>> consumablesMap = [
    {
      // No consumable
      'consumable': 'No consumable',
      'consumableName': '',
      'consumableDescription': '',
    },
    {
      // Clearance sale consumable
      'consumable': 'images/consumables/Clearance_Sale.png',
      'consumableName': 'Clearance Sale',
      'consumableDescription': 'Clearence sell:Next shop its 50% off!',
    },
    {
      // Death consumable
      'consumable': 'images/consumables/death.png',
      'consumableName': 'Death',
      'consumableDescription': '',
    },
    {
      // Crystal ball consumable
      'consumable': 'images/consumables/Crystal_Ball.png',
      'consumableName': 'Crystal Ball',
      'consumableDescription':
          'Crystal Ball: 25% chance to replace a normal card with an ace next round',
    },
  ];

  // List of jokers with image path, name, and description
  List<Map<String, String>> jokersMap = [
    {
      // No joker
      'joker': 'No jocker',
      'jokerName': 'No jocker',
      'jokerDescription': '',
    },
    {
      // Average size Michael joker
      'joker': 'images/jokers/AVERAGE_SIZE_MICHAEL.png',
      'jokerName': 'Average SizeMichael',
      'jokerDescription':
          'Average size Michael +13 mult.1/13 chance of being sold each round. Glass:This is a tooltip For the glass overlay',
    },
    {
      // Solid Seven joker
      'joker': 'images/jokers/solid_seven.png',
      'jokerName': 'Solid Seven',
      'jokerDescription': '',
    },
    {
      // Average size Michael joker
      'joker': 'images/jokers/AVERAGE_SIZE_MICHAEL.png',
      'jokerName': 'Average SizeMichael',
      'jokerDescription':
          'Average size Michael +13 mult.1/13 chance of being sold each round. Glass:This is a tooltip For the glass overlay',
    },
    {
      // Solid Seven joker
      'joker': 'images/jokers/solid_seven.png',
      'jokerName': 'Solid Seven',
      'jokerDescription': '',
    },
  ];

  // List of packages with image path, internal name, and description
  List<Map<String, String>> packagesMap = [
    {
      // No package
      'package': 'No package',
      'packageName': 'No package',
      'packageDescription': '',
    },
    {
      // Buffon Normal
      'package': 'images/packages/Buffoon_Normal_2.png',
      'packageName': 'Buffoon Normal',
      'packageDescription': '',
    },
    {
      // Spectral Jumbo
      'package': 'images/packages/Spectral_Jumbo_1.png',
      'packageName': 'Spectral Jumbo',
      'packageDescription': '',
    },
    {
      // Standard Normal
      'package': 'images/packages/Standard_Normal_1.png',
      'packageName': 'Standard Normal',
      'packageDescription': '',
    },
  ];

  /// Get the image path for a package by its subtype
  String getPackageImageBySubtype(int subtype) {
    // Search for the package in the list using the subtype
    if (subtype < 0 || subtype >= packagesMap.length) return 'No package';
    return packagesMap[subtype]['package'] ?? 'No package';
  }

  /// Get the image path for a consumable by its subtype
  String getConsumableImageBySubtype(int subtype) {
    // Search for the consumable in the list using the subtype
    if (subtype < 0 || subtype >= consumablesMap.length) return 'No consumable';
    return consumablesMap[subtype]['consumable'] ?? 'No consumable';
  }

  /// Get the image path for a joker by its subtype
  String getJokerImageBySubtype(int subtype) {
    // Search for the joker in the list using the subtype
    if (subtype < 0 || subtype >= jokersMap.length) return 'No joker';
    return jokersMap[subtype]['joker'] ?? 'No joker';
  }
}
