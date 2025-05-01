import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nogler/dialogs/game_dialogs.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_cards_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';
import 'package:playing_cards/playing_cards.dart';

class BuyWidget extends StatefulWidget {
  const BuyWidget({
    super.key,
    required this.shopWidgetKey,
    required this.jokerCardsKey,
    required this.consumableCardsKey,
    required this.onBuy,
    required this.gold,
  });

  final GlobalKey<ShopWidgetState> shopWidgetKey;
  final GlobalKey<JokerCardsState> jokerCardsKey;
  final GlobalKey<OwnedConsumableCardsState> consumableCardsKey;
  final Function(int)? onBuy;
  final int gold;

  @override
  BuyWidgetState createState() => BuyWidgetState();
}

class BuyWidgetState extends State<BuyWidget> {
  // Initialized because the compiler is mad
  PurchasableItemInfo draggedItem = PurchasableItemInfo(
    price: 0,
    id: -1,
    index: -1,
    type: "",
    subtype: 0,
    cardName: "",
  );
  // Websocket client
  final WebSocketClient wsClient = WebSocketClient();
  // Get the info of dragged item
  Future<void> setDraggedItem(PurchasableItemInfo currentDragged) async {
    setState(() {
      draggedItem = currentDragged;
    });
  }

  // Generate items for the package
  List<PurchasableItemInfo> _generateItemsForPackage(int subtype) {
    switch (subtype) {
      case 2: // Spectral Jumbo Pack
        return [
          PurchasableItemInfo(
            price: 0,
            id: 1,
            index: -1,
            type: "consumable",
            subtype: 1,
            cardName: "",
          ),
          PurchasableItemInfo(
            price: 0,
            id: 2,
            index: -1,
            type: "consumable",
            subtype: 2,
            cardName: "",
          ),
          PurchasableItemInfo(
            price: 0,
            id: 3,
            index: -1,
            type: "consumable",
            subtype: 3,
            cardName: "",
          ),
        ];
      case 1: // Buffoon Normal Pack
        return [
          PurchasableItemInfo(
            price: 0,
            id: 1,
            index: -1,
            type: "joker",
            subtype: 1,
            cardName: "",
          ),
          PurchasableItemInfo(
            price: 0,
            id: 2,
            index: -1,
            type: "joker",
            subtype: 2,
            cardName: "",
          ),
        ];
      case 3: // Standard Normal Pack - Ahora con cartas aleatorias
        final random = Random();
        final suits = Suit.values;
        final values = CardValue.values;

        // Generate 3 unique cards
        final Set<PlayingCard> uniqueCards = {};
        while (uniqueCards.length < 3) {
          final suit = suits[random.nextInt(suits.length)];
          final value = values[random.nextInt(values.length)];
          uniqueCards.add(PlayingCard(suit, value));
        }
        // Convert the unique cards to a list of PurchasableItemInfo
        return uniqueCards.map((card) {
          return PurchasableItemInfo(
            price: 0,
            id: card.hashCode,
            index: -1,
            type: "card",
            subtype: 0,
            cardName: _playingCardToImageId(card),
          );
        }).toList();
      default:
        return [];
    }
  }

  /// Converts a PlayingCard to an image ID string.
  /// The image ID is a string that represents the card's value and suit.
  String _playingCardToImageId(PlayingCard card) {
    // Convert the card value to a string
    String valueStr;
    switch (card.value) {
      case CardValue.ace:
        valueStr = 'A';
        break;
      case CardValue.two:
        valueStr = '2';
        break;
      case CardValue.three:
        valueStr = '3';
        break;
      case CardValue.four:
        valueStr = '4';
        break;
      case CardValue.five:
        valueStr = '5';
        break;
      case CardValue.six:
        valueStr = '6';
        break;
      case CardValue.seven:
        valueStr = '7';
        break;
      case CardValue.eight:
        valueStr = '8';
        break;
      case CardValue.nine:
        valueStr = '9';
        break;
      case CardValue.ten:
        valueStr = '10';
        break;
      case CardValue.jack:
        valueStr = 'J';
        break;
      case CardValue.queen:
        valueStr = 'Q';
        break;
      case CardValue.king:
        valueStr = 'K';
        break;
      default:
        valueStr = 'A';
    }

    // Convert the card suit to a string
    String suitStr;
    switch (card.suit) {
      case Suit.hearts:
        suitStr = 'H';
        break;
      case Suit.diamonds:
        suitStr = 'D';
        break;
      case Suit.clubs:
        suitStr = 'C';
        break;
      case Suit.spades:
        suitStr = 'S';
        break;
      default:
        suitStr = 'H';
    }
    debugPrint("Card: $valueStr$suitStr");
    // Return the image ID string
    return '$valueStr$suitStr';
  }

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
        onAcceptWithDetails: (
          DragTargetDetails<PurchasableItemInfo> dragged,
        ) async {
          switch (dragged.data.type) {
            case "joker":
              if (widget.gold >= dragged.data.price &&
                  widget.jokerCardsKey.currentState!.jokersOwned.length < 5) {
                wsClient.sendMessage("buy_joker", {
                  dragged.data.id,
                  dragged.data.price,
                });
                widget.shopWidgetKey.currentState?.removeJoker(
                  dragged.data.index,
                  false,
                );
              }
              break;
            case "consumable":
              if (widget.gold >= dragged.data.price) {
                wsClient.sendMessage("buy_voucher", {
                  dragged.data.id,
                  dragged.data.price,
                });
                widget.shopWidgetKey.currentState?.removeConsumable(
                  dragged.data.index,
                  false,
                );
                widget.onBuy?.call(dragged.data.price);
              }
              break;
            case "package":
              // Create a list of items for the package
              final availableItems = _generateItemsForPackage(
                dragged.data.subtype,
              );

              //Show the dialog to select the item
              final selectedItem = await showVoucherPackDialog(
                context,
                dragged.data.subtype,
                availableItems,
              );

              debugPrint("Selected item: ${selectedItem?.type}");
              // Check if the user selected an item
              if (selectedItem != null) {
                // Add the item to the jocker or consumable list
                if (selectedItem.type == "consumable") {
                  widget.consumableCardsKey.currentState?.addConsumableOwned(
                    selectedItem,
                    true,
                  );
                } else if (selectedItem.type == "joker") {
                  debugPrint("Joker added to owned list");
                  widget.jokerCardsKey.currentState?.addJokerOwned(
                    selectedItem,
                    true,
                  );
                }
              }
              // Remove the package from the shop widget
              widget.shopWidgetKey.currentState?.removePackage(
                dragged.data.index,
              );
              widget.onBuy?.call(dragged.data.price);
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
              "Buy\n\$ ${draggedItem.price}",
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
