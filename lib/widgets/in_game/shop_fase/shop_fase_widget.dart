import 'package:flutter/material.dart';
import 'package:nogler/dialogs/game_dialogs.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/sell_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';

/// This widget represents the shop phase in the game.
/// It contains the shop widget, buy widget, and sell widget.
class ShopFaseWidget extends StatefulWidget {
  const ShopFaseWidget({
    super.key,
    required this.shopWidgetKey,
    required this.buyWidgetKey,
    required this.jokerCardsKey,
    required this.consumableCardsKey,
    required this.sellWidgetKey,
    required this.onBuy,
    required this.onSell,
    required this.onReroll,
    required this.shopJokers,
    required this.gold,
    required this.shopConsumables,
    required this.shopPackages,
    required this.priceReroll,
  });

  final GlobalKey<ShopWidgetState> shopWidgetKey;
  final GlobalKey<JokerCardsState> jokerCardsKey;
  final GlobalKey<OwnedConsumableCardsState> consumableCardsKey;
  final GlobalKey<BuyWidgetState> buyWidgetKey;
  final GlobalKey<SellWidgetState> sellWidgetKey;
  final Function(int)? onBuy;
  final Function(int)? onSell;
  final Function(int, int)? onReroll;
  final List<PurchasableItemInfo> shopJokers;
  final int gold;
  final List<PurchasableItemInfo> shopConsumables;
  final List<PurchasableItemInfo> shopPackages;
  final int priceReroll;

  @override
  State<ShopFaseWidget> createState() => ShopFaseWidgetState();
}

class ShopFaseWidgetState extends State<ShopFaseWidget> {
  bool buyWidgetVisible = false;
  bool sellWidgetVisible = false;
  List<Map<String, dynamic>> purchasedCards = [];
  List<Map<String, dynamic>> purchasedJokers = [];
  List<Map<String, dynamic>> purchasedVouchers = [];
  // Websocket client
  final WebSocketClient wsClient = WebSocketClient();
  Future<void> onDraggedItem() async {
    setState(() {
      buyWidgetVisible = true;
    });
  }

  List<PurchasableItemInfo> generateItemsForPackage(
    int packType,
    List<Map<String, dynamic>> purchasedCards,
    List<Map<String, dynamic>> purchasedJokers,
    List<Map<String, dynamic>> purchasedVouchers,
  ) {
    final List<PurchasableItemInfo> items = [];

    switch (packType) {
      case 1: // Standard Normal Pack
        for (var card in purchasedCards) {
          items.add(
            PurchasableItemInfo(
              price: 0,
              id: card['id'] ?? 0,
              index: -1,
              type: 'card',
              subtype: 0,
              rank: '${card['Rank']}',
              suit: '${card['Suit']}',
              overlay: card['Enhancement'],
            ),
          );
        }
        break;
      case 2: // Buffoon Normal Pack
        for (var jokerEntry in purchasedJokers) {
          jokerEntry.forEach((type, jokerList) {
            for (var joker in jokerList) {
              items.add(
                PurchasableItemInfo(
                  price: joker['sell_price'] ?? 0,
                  id: 0,
                  index: -1,
                  type: 'joker',
                  subtype: joker['id'],
                  rank: '',
                  suit: '',
                  overlay: 0,
                ),
              );
            }
          });
        }
        break;

      case 3: // Spectral Jumbo Pack
        for (var voucher in purchasedVouchers) {
          items.add(
            PurchasableItemInfo(
              price: 0,
              id: 0,
              index: -1,
              type: 'consumable',
              subtype: voucher['value'] ?? 0,
              rank: '',
              suit: '',
              overlay: 0,
            ),
          );
        }
        break;
      default:
        break;
    }

    return items;
  }

  @override
  void initState() {
    super.initState();

    // Listerner for a bought joker
    wsClient.addEventListener("joker_purchased", (data) {
      int itemId = data["item_id"];
      int jokerId = data["joker_id"];
      int sellPrice = data["sell_price"];
      int remainingMoney = data["remaining_money"];

      // Create the new PurchasableItemInfo
      PurchasableItemInfo purchasedJoker = PurchasableItemInfo(
        price: sellPrice,
        id: itemId,
        index: -1,
        type: "owned joker",
        subtype: jokerId,
        rank: '',
        suit: '',
        overlay: 0,
      );

      widget.jokerCardsKey.currentState?.addJokerOwned(purchasedJoker, false);

      widget.onBuy?.call(remainingMoney);
    });

    // Listerner for a bought voucher
    wsClient.addEventListener("voucher_purchased", (data) {
      int itemId = data["item_id"];
      int voucherId = data["voucher_id"];
      int remainingMoney = data["remaining_money"];
      PurchasableItemInfo purchasedJoker = PurchasableItemInfo(
        price: 0,
        id: itemId,
        index: -1,
        type: "owned consumable",
        subtype: voucherId,
        rank: '',
        suit: '',
        overlay: 0,
      );

      widget.consumableCardsKey.currentState?.addConsumableOwned(
        purchasedJoker,
        false,
      );

      widget.onBuy?.call(remainingMoney);
    });

    // Listerner for a sold joker
    wsClient.addEventListener("joker_sold", (data) {
      int remainingMoney = data["remaining_money"];
      widget.onSell?.call(remainingMoney);
    });

    // Listerner for a sold voucher
    wsClient.addEventListener("pack_purchased", (data) async {
      purchasedCards = [];
      purchasedJokers = [];
      purchasedVouchers = [];
      purchasedCards = List<Map<String, dynamic>>.from(data["cards"] ?? []);
      purchasedJokers = List<Map<String, dynamic>>.from(data["jokers"] ?? []);
      purchasedVouchers = List<Map<String, dynamic>>.from(
        data["vouchers"] ?? [],
      );
      final packType = data["pack_type"];
      final maxSelected = data["max_selectable"];
      int remainingMoney = data["remaining_money"];
      debugPrint("💾 Cards: $purchasedCards");
      debugPrint("🃏 Jokers: $purchasedJokers");
      debugPrint("🎟️ Vouchers: $purchasedVouchers");
      final itemId = data["item_id"];

      widget.onBuy?.call(remainingMoney);
      // Create a list of items for the package
      final availableItems = generateItemsForPackage(
        packType,
        purchasedCards,
        purchasedJokers,
        purchasedVouchers,
      );
      // Imprime la longitud de la lista
      debugPrint('Length of availableItems: ${availableItems.length}');

      // Imprime el contenido de la lista
      debugPrint('Content of availableItems: $availableItems');
      // Show the dialog to select the item
      final selectedItem = await showVoucherPackDialog(
        context,
        packType,
        availableItems,
        maxSelected,
      );

      final Map<String, dynamic> selectionsMap = {
        "selectedCards": [],
        "selectedJokers": [],
        "selectedVouchers": [],
      };

      if (selectedItem != null) {
        // Check if the user selected an item
        for (final item in selectedItem) {
          switch (item.type) {
            case "card":
              selectionsMap["selectedCards"].add({
                "Rank": item.rank,
                "Suit": item.suit,
                "Enhancement": item.overlay,
              });
              break;
            case "joker":
              selectionsMap["selectedJokers"].add(item.subtype);
              break;
            case "consumable":
              selectionsMap["selectedVouchers"].add(item.subtype);
              break;
          }
        }
      }

      // Remove the selected items from the purchased list
      if (packType == 1) {
        selectionsMap.remove("selectedJokers");
        selectionsMap.remove("selectedVouchers");
      } else if (packType == 2) {
        selectionsMap.remove("selectedCards");
        selectionsMap.remove("selectedVouchers");
      } else if (packType == 3) {
        selectionsMap.remove("selectedCards");
        selectionsMap.remove("selectedJokers");
      }

      // Send the selected items to the server
      wsClient.sendMessage("choose_pack_items", {itemId, selectionsMap});

      // Listener for the completion of the pack selection
      wsClient.addEventListener("pack_selection_complete", (data) {
        switch (packType) {
          case 2: // Buffoon Normal Pack
            for (final item in selectedItem!) {
              if (item.type == "joker") {
                widget.jokerCardsKey.currentState?.addJokerOwned(item, true);
              }
            }
            break;

          case 3: // Spectral Jumbo Pack
            for (final item in selectedItem!) {
              if (item.type == "consumable") {
                widget.consumableCardsKey.currentState?.addConsumableOwned(
                  item,
                  true,
                );
              }
            }
            break;

          default:
            break;
        }
      });
    });
  }

  Future<void> onDroppedItem() async {
    setState(() {
      buyWidgetVisible = false;
    });
  }

  Future<void> onDraggedSellItem() async {
    setState(() {
      sellWidgetVisible = true;
    });
  }

  Future<void> onDropSellItem() async {
    setState(() {
      sellWidgetVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShopWidget(
          key: widget.shopWidgetKey,
          buyWidgetKey: widget.buyWidgetKey,
          ownedJokersWidgetKey: widget.jokerCardsKey,
          onDraggedItem: onDraggedItem,
          onDroppedItem: onDroppedItem,
          onReroll: widget.onReroll,
          shopJokers: widget.shopJokers,
          shopConsumables: widget.shopConsumables,
          shopPackages: widget.shopPackages,
          priceReroll: widget.priceReroll,
        ),
        Visibility(
          visible: buyWidgetVisible,
          child: BuyWidget(
            key: widget.buyWidgetKey,
            shopWidgetKey: widget.shopWidgetKey,
            jokerCardsKey: widget.jokerCardsKey,
            consumableCardsKey: widget.consumableCardsKey,
            onBuy: widget.onBuy,
            gold: widget.gold,
          ),
        ),
        Visibility(
          visible: sellWidgetVisible,
          child: SellWidget(
            key: widget.sellWidgetKey,
            jokerCardsKey: widget.jokerCardsKey,
            consumableCardsKey: widget.consumableCardsKey,
            onSell: widget.onSell,
          ),
        ),
      ],
    );
  }
}
