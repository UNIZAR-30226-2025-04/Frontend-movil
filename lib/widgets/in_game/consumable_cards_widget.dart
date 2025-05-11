import 'package:flutter/material.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/in_game/consumable_fase/consumable_fase_widget.dart';
import 'package:nogler/widgets/in_game/consumable_fase/use_consumable_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/sell_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_fase_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';

/// A widget that displays a row of Joker cards.
/// The number of cards is generated dynamically and displayed below.
class OwnedConsumableCards extends StatefulWidget {
  const OwnedConsumableCards({
    super.key,
    required this.consumableOwned,
    required this.onAddConsumableOwned,
    required this.onRemoveConsumableOwned,
    required this.onRemoveAllConsumableOwned,
    required this.shopFaseWidgetKey,
    required this.consumableFaseWidgetKey,
    required this.shopWidgetKey,
    required this.buyWidgetKey,
    required this.sellWidgetKey,
  });

  final List<PurchasableItemInfo> consumableOwned;
  final Function(PurchasableItemInfo)? onAddConsumableOwned;
  final Function(PurchasableItemInfo)? onRemoveConsumableOwned;
  final void Function() onRemoveAllConsumableOwned;
  final GlobalKey<ShopFaseWidgetState> shopFaseWidgetKey;
  final GlobalKey<ConsumableFaseWidgetState> consumableFaseWidgetKey;
  final GlobalKey<ShopWidgetState> shopWidgetKey;
  final GlobalKey<BuyWidgetState> buyWidgetKey;
  final GlobalKey<SellWidgetState> sellWidgetKey;

  @override
  OwnedConsumableCardsState createState() => OwnedConsumableCardsState();
}

class OwnedConsumableCardsState extends State<OwnedConsumableCards> {
  // List of Joker cards to be displayed
  List<PurchasableItemInfo> _consumableOwned = [];

  final WebSocketClient wsClient = WebSocketClient();

  /// This function checks if the list is full (5 elements)
  /// if it isn't, we add the consumable to the list and remove it from the shop
  /// if it is we do nothing
  ///   this function is called from "buy_widget"
  Future<void> addConsumableOwned(
    PurchasableItemInfo consumableInfo,
    bool isPackage,
  ) async {
    setState(() {
      // Add it to your owned list
      final PurchasableItemInfo auxConsumableInfo = PurchasableItemInfo(
        price: consumableInfo.price,
        id: consumableInfo.id,
        index: -1, // Not used
        type: "owned consumable",
        subtype: consumableInfo.subtype,
        rank: '',
        suit: '',
        overlay: 0,
      );
      _consumableOwned.add(auxConsumableInfo);
      debugPrint("Consumible añadido en la lista");
    });
  }

  /// This function removes the consumable from the owned list
  Future<void> removeConsumableOwned(PurchasableItemInfo jokerInfo) async {
    setState(() {
      if (_consumableOwned.isNotEmpty) {
        // Remove the consumable from the owned list
        _consumableOwned.remove(jokerInfo);
        //widget.onRemoveConsumableOwned!(jokerInfo);
        debugPrint("Consumible eliminado de la lista");
      } else {
        debugPrint("No hay consumibles para eliminar");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _consumableOwned = widget.consumableOwned;

    wsClient.addEventListener("modifiers_sended", (data) {
      debugPrint("📡 Received modifiers_sended info: $data");

      setState(() {
        widget.onRemoveAllConsumableOwned();
        _consumableOwned = [];
        for (var mod in data['modifiers']['Modificadores']) {
          int aux = mod['value'];
          PurchasableItemInfo auxPurchasable = PurchasableItemInfo(
            price: 0,
            id: -1,
            index: -1,
            type: "owned consumable",
            subtype: aux,
            rank: "",
            suit: "",
            overlay: 0,
          );
          _consumableOwned.add(auxPurchasable);
          widget.onAddConsumableOwned!(auxPurchasable);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Displays the label for active consumables.
            Text(
              "Owned consumables",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        // Displays the row of Consumable cards.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                _consumableOwned.isEmpty
                    ? [SizedBox(height: 68)]
                    : List.generate(_consumableOwned.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Joker(
                          purchasableItemInfo: _consumableOwned[index],
                          // Display sell widget
                          onDraggedItem: () {
                            widget.consumableFaseWidgetKey.currentState
                                ?.onDraggedConsumable();
                            return;
                          },

                          onDroppedItem: () {
                            widget.consumableFaseWidgetKey.currentState
                                ?.onDroppedConsumable();
                            return;
                          },
                          keyWidget: widget.sellWidgetKey,
                        ),
                      );
                    }),
          ),
        ),
      ],
    );
  }
}

class UsedConsuambleCards extends StatefulWidget {
  const UsedConsuambleCards({
    super.key,
    required this.consumableUsed,
    required this.onAddConsumableUsed,
    required this.onRemoveConsumableUsed,
    required this.consumableFaseWidgetKey,
    required this.useConsumableWidgetKey,
  });

  final List<PurchasableItemInfo> consumableUsed;
  final Function(PurchasableItemInfo)? onAddConsumableUsed;
  final Function(PurchasableItemInfo)? onRemoveConsumableUsed;
  final GlobalKey<ConsumableFaseWidgetState> consumableFaseWidgetKey;
  final GlobalKey<UseConsumableWidgetState> useConsumableWidgetKey;

  @override
  UsedConsumableCardsState createState() => UsedConsumableCardsState();
}

class UsedConsumableCardsState extends State<UsedConsuambleCards> {
  // List of Joker cards to be displayed
  List<PurchasableItemInfo> consumableUsed = [];

  final WebSocketClient wsClient = WebSocketClient();

  /// Adds the used consumable to the consumableUsed list
  Future<void> addConsumableUsed(PurchasableItemInfo jokerInfo) async {
    setState(() {
      // Add it to your owned list
      final PurchasableItemInfo auxJokerInfo = PurchasableItemInfo(
        price: jokerInfo.price,
        id: jokerInfo.id,
        index: -1, // Not used
        type: "owned consumable",
        subtype: jokerInfo.subtype,
        rank: '',
        suit: '',
        overlay: 0,
      );
      consumableUsed.add(auxJokerInfo);
    });
  }

  /// This function removes the consumable from the used list
  Future<void> removeConsumableUsed(PurchasableItemInfo jokerInfo) async {
    setState(() {
      if (consumableUsed.isNotEmpty) {
        // Remove the consumable from the owned list
        consumableUsed.remove(jokerInfo);
        widget.onRemoveConsumableUsed!(jokerInfo);
        debugPrint("Consumible eliminado de la lista");
      } else {
        debugPrint("No hay consumibles para eliminar");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    consumableUsed = widget.consumableUsed;

    // Listener to receive the modifiers activated by other users in the lobby
    wsClient.addEventListener("modifiers_received", (data) {
      debugPrint("📡 Received modifiers_received info: $data");
      setState(() {
        for (var item in data['modifiers']['modifiers']) {
          int aux = item['modifier']['value'];
          consumableUsed.add(
            PurchasableItemInfo(
              price: 0,
              id: -1,
              index: -1,
              type: "owned consumable",
              subtype: aux,
              rank: "",
              suit: "",
              overlay: 0,
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Displays the label for active consumables.
            Text(
              "Active effects",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        // Displays the row of Consumable cards.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                consumableUsed.isEmpty
                    ? [SizedBox(height: 68)]
                    : List.generate(consumableUsed.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Joker(
                          purchasableItemInfo: consumableUsed[index],
                          keyWidget: widget.useConsumableWidgetKey,
                        ),
                      );
                    }),
          ),
        ),
      ],
    );
  }
}
