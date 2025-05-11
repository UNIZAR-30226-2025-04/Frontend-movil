import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/sell_widget.dart';

/// Info about the vouchers/consumables, jokers and packages
class PurchasableItemInfo {
  PurchasableItemInfo({
    required this.price,
    required this.id,
    required this.index,
    required this.type,
    required this.subtype,
    required this.rank,
    required this.suit,
    required this.overlay,
  });

  /// Price of the card
  final int price;

  /// The id of the item defines the image and effect related to that item
  /// Same id can be either a joker, voucher/consumable or package
  final int id;

  /// Index in the list where the item is displayed
  /// Needed to iterate move the items in between the list
  int index;

  /// String type among these values: "joker" or "owned joker", "consumable" or "owned consumable", "package"
  final String type;

  final int subtype;
  String rank = "";
  String suit = "";
  int overlay = 0;
}

/// This widget is used to display a joker card with an overlay effect.
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
    final isJoker =
        widget.purchasableItemInfo.type == "joker" ||
        widget.purchasableItemInfo.type == "owned joker";

    return Stack(
      children: [
        Container(
          width: isJoker ? 49 : 57,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: isJoker ? BorderRadius.circular(5) : null,
            border:
                isJoker
                    ? Border.all(color: Color(0x70000000), width: 0.2)
                    : null,
            boxShadow: [
              if (isJoker)
                BoxShadow(
                  offset: Offset(5, 15),
                  blurRadius: 10,
                  color: Color(0x70000000),
                ),
            ],
          ),

          child:
              // Consumables images
              (widget.purchasableItemInfo.type == "consumable" ||
                      widget.purchasableItemInfo.type == "owned consumable")
                  ? Image.asset(
                    getConsumableImageBySubtype(
                      widget.purchasableItemInfo.subtype,
                    ),
                    fit: BoxFit.cover,
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
                    fit: BoxFit.cover,
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
                    getPackageImageBySubtype(
                      widget.purchasableItemInfo.subtype,
                    ),
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
        ),
        if (isJoker)
          SizedBox(
            width: 49,
            height: height,
            child: Image.asset("images/cards_overlay/joker overlay.png"),
          ),
      ],
    );
  }

  /// Shows the description of the card onLongPress
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

  // List of jokers with image path, name, and description
  List<Map<String, String>> jokersMap = [
    {
      // 0. No joker
      'joker': 'No jocker',
      'jokerName': 'No jocker',
      'jokerDescription': '',
    },
    {
      // 1. Solid Seven joker
      'joker': 'images/jokers/solid_seven.png',
      'jokerName': 'Solid Seven',
      'jokerDescription': 'Solid Seven +7 chips +7 mult',
    },
    {
      // 2. Poor joker
      'joker': 'images/jokers/poor_joker.png',
      'jokerName': 'Poor joker',
      'jokerDescription': 'Poor joker generates 4 gold each round',
    },
    {
      // 3. Petpet joker
      'joker': 'images/jokers/pet-pet-petpet.gif',
      'jokerName': 'Petpet',
      'jokerDescription': 'Petpet sums the number of gold the user has to mult',
    },
    {
      // 4. Average size Michael joker
      'joker': 'images/jokers/banana.gif',
      'jokerName': 'Average Size Michael',
      'jokerDescription':
          'Average size Michael +15 mult, 1/15 chance of being sold each round',
    },
    {
      // 5. Hell Cowboy joker
      'joker': 'images/jokers/hell.gif',
      'jokerName': 'Hell Cowboy',
      'jokerDescription':
          'Hell Cowboy adds +mult equivalent to the highest scoring card',
    },
    {
      // 6. Carb Sponge joker
      'joker': 'images/jokers/bob_spider.png',
      'jokerName': 'Crab Sponge',
      'jokerDescription':
          'Crab Sponge +50 chips if you have 3 identical cards in your played hand',
    },
    {
      // 7. Two Friends joker
      'joker': 'images/jokers/doge.gif',
      'jokerName': 'Two Friends',
      'jokerDescription':
          'Two Friends takes 10 of your +chips and changes them to +mult. But if your chips < 10, doesnt subtract from chips, just add 10-chips to mult',
    },
    {
      // 8. BIRDIFICACION joker
      'joker': 'images/jokers/birdification.png',
      'jokerName': 'BIRDIFICACION',
      'jokerDescription': 'BIRDIFICACION +50 chips for each 1,4,6,7',
    },
    {
      // 9. Photograph joker
      'joker': 'images/jokers/PHOTOGRAPH.png',
      'jokerName': 'Photograph',
      'jokerDescription': 'Photograph x2 multiplies the first figure you play',
    },
    {
      // 10. Empty joker
      'joker': 'images/jokers/empty_joker.png',
      'jokerName': 'Empty',
      'jokerDescription':
          'Empty 1/50 of adding 200 to the mult and 25 to the chips',
    },
    {
      // 11. Lirili Larila
      'joker': 'images/jokers/lirili.gif',
      'jokerName': 'Lirili Larila',
      'jokerDescription':
          'Lirili Larila +2 to mult for each played / scoring 2 then x2 mult',
    },
    {
      // 12. Rusty ahh joker
      'joker': 'images/jokers/rusty_ahh_joker.png',
      'jokerName': 'Rusty ahh joker',
      'jokerDescription':
          'Rusty ahh joker gold won before this joker applies = 0 but 2x mult',
    },
    {
      // 13. Damn April joker
      'joker': 'images/jokers/damn_april.jpg',
      'jokerName': 'Damn April',
      'jokerDescription':
          'Damn April randomizes chips and multipliers but guarantees at least +14 total',
    },
    {
      // 14. Crowave joker
      'joker': 'images/jokers/crowave.png',
      'jokerName': 'Crowave',
      'jokerDescription':
          'Crowave grants +3 to the multiplier for each red card with a 90% probability. 10% of the time, grants +5 chips per red card',
    },
    {
      // 15. Bicycle joker
      'joker': 'images/jokers/bicicleta.gif',
      'jokerName': 'Bicycle',
      'jokerDescription': 'Bicycle every 2 gives +2 mult and +20 chips',
    },
    {
      // 16. Balatrito comes out joker
      'joker': 'images/jokers/salebalatrito.png',
      'jokerName': 'Balatrito comes out',
      'jokerDescription': 'Balatrito comes out +50 chips if trio',
    },
    {
      // 17. Diego joker
      'joker': 'images/jokers/diego_joker.png',
      'jokerName': 'Diego',
      'jokerDescription':
          'Diego if you play exactly 3 cards, multiply your multiplier x4',
    },
    {
      // 18. Its so over joker
      'joker': 'images/jokers/its_so_over.png',
      'jokerName': 'Its so over',
      'jokerDescription':
          'Its so over +10 gold if only 1 card is played (hand size 1)',
    },
    {
      // 19. Paris joker
      'joker': 'images/jokers/paris.png',
      'jokerName': 'Paris',
      'jokerDescription':
          'Paris +3 mult for each pair of cards of the same suit',
    },
    {
      // 20. Nasus joker
      'joker': 'images/jokers/nas.gif',
      'jokerName': 'Nasus',
      'jokerDescription': 'Nasus multiplies your gold by the mult',
    },
    {
      // 21. Umbrella joker
      'joker': 'images/jokers/sombrilla.png',
      'jokerName': 'Umbrella',
      'jokerDescription':
          'Umbrella every grants +20 multiplier when only number cards (J, Q, K, A) are played in the hand',
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
      // Standard Normal
      'package': 'images/packages/Standard_Normal_1.png',
      'packageName': 'Standard Normal',
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

List<Map<String, String>> consumablesMap = [
  {
    // No consumable
    'consumable': 'No consumable',
    'consumableName': '',
    'consumableDescription': '',
    'consumableTargets': '',
  },
  {
    // 1. Damn consumable
    'consumable': 'images/consumables/voucher damn.png',
    'consumableName': 'Damn',
    'consumableDescription': 'Divide starting chips and mult by half',
    'consumableTargets': '3',
  },
  {
    // 2. PabloHoney consumable
    'consumable': 'images/consumables/voucher pablo honey.png',
    'consumableName': 'PabloHoney',
    'consumableDescription': 'Earn 1 dollar for each card played.',
    'consumableTargets': '0',
  },
  {
    // 3. RAM consumable
    'consumable': 'images/consumables/voucher RAM.png',
    'consumableName': 'RAM',
    'consumableDescription':
        'Multiplies your chips to a random number between 1 and 3',
    'consumableTargets': '0',
  },
  {
    // 4. Weezer consumable
    'consumable': 'images/consumables/voucher weezer .png',
    'consumableName': 'Weezer',
    'consumableDescription':
        'Bans up to 4 players to play four of a kind for 1 round',
    'consumableTargets': '4',
  },
  {
    // 5. Blond consumable
    'consumable': 'images/consumables/voucher blond.png',
    'consumableName': 'Blond',
    'consumableDescription':
        'Bans up to 2 players from playing straights for 1 round.',
    'consumableTargets': '2',
  },
  {
    // 6. abbeyRoad consumable
    'consumable': 'images/consumables/voucher abbey road.png',
    'consumableName': 'abbeyRoad',
    'consumableDescription':
        'Every King or Queen played scores negative points',
    'consumableTargets': '4',
  },
  {
    // 7. Rock transgresivo consumable
    'consumable': 'images/consumables/voucher extremoduro.png',
    'consumableName': 'Rock transgresivo',
    'consumableDescription': 'Aces and K’s score double',
    'consumableTargets': '0',
  },
  {
    // 8. Diamond Eyes consumable
    'consumable': 'images/consumables/voucher deftones.png',
    'consumableName': 'Diamond Eyes',
    'consumableDescription': 'Subtracts from their mult the money they have.',
    'consumableTargets': '3',
  },
  {
    // 9. The money store consumable
    'consumable': 'images/consumables/voucher victor.png',
    'consumableName': 'The money store',
    'consumableDescription':
        'Each black card played (spades and clubs) grants 1 dollar, +10 chips, +2 mult',
    'consumableTargets': '0',
  },
];
