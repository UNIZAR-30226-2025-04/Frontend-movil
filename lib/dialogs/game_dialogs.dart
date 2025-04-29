import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nogler/screens/home/home_screen.dart';
import 'package:nogler/widgets/in_game/card_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/player_box_consumables.dart';
import 'package:page_transition/page_transition.dart';
import 'package:playing_cards/playing_cards.dart';

/// Displays a dialog showing the types of hands in the game.
Future<void> showHandTypes(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 400,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3454),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hand types',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'X',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lista scrollable
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    _buildDataRow('lvl.1', 'Flush five', '35', 'X', '25'),
                    _buildDataRow('lvl.1', 'Flush house', '32', 'X', '22'),
                    _buildDataRow('lvl.1', 'Five of a kind', '30', 'X', '20'),
                    _buildDataRow('lvl.1', 'Royal flush', '65', 'X', '50'),
                    _buildDataRow('lvl.1', 'Straight flush', '50', 'X', '40'),
                    _buildDataRow('lvl.1', 'Four of a kind', '25', 'X', '15'),
                    _buildDataRow('lvl.1', 'Full house', '20', 'X', '12'),
                    _buildDataRow('lvl.1', 'Flush', '15', 'X', '8'),
                    _buildDataRow('lvl.1', 'Straight', '12', 'X', '5'),
                    _buildDataRow('lvl.1', 'Three of a kind', '10', 'X', '4'),
                    _buildDataRow('lvl.1', 'Two pair', '8', 'X', '3'),
                    _buildDataRow('lvl.1', 'One pair', '4', 'X', '2'),
                    _buildDataRow('lvl.1', 'High card', '1', 'X', '1'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Builds a data row for the hand types dialog.
Widget _buildDataRow(
  String level,
  String type,
  String points,
  String x,
  String multiplier,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    child: Row(
      children: [
        // Level
        Container(
          width: 60,
          height: 30,
          decoration: BoxDecoration(
            color: Color(0xFF495a8f),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              level,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Type
        Expanded(
          child: Center(
            child: Text(
              type,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Points, X, and Multiplier
        Container(
          width: 150,
          decoration: BoxDecoration(
            color: Color(0xFF495a8f),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Spacing between children
            children: [
              // Points at the left
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0ea5e9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    points,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // X in the middle
              const Text(
                'X',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Multiplier at the right
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFd41976),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    multiplier,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Displays a dialog to choose a joker, a consumible item or a card.
Future<PurchasableItemInfo?> showVoucherPackDialog(
  BuildContext context,
  int subtype,
  List<PurchasableItemInfo> availableItems,
) async {
  // Lists to hold the displayed items and selected index
  List<PurchasableItemInfo> displayedItems = [];
  List<int> selectedIndexes = [];

  return await showDialog<PurchasableItemInfo>(
    context: context,
    barrierDismissible: false, // Prevents closing the dialog by tapping outside
    builder: (BuildContext context) {
      String title = "";
      String subtitle = "";
      Widget content = const SizedBox();
      int maxChoices = 1; // Default max choices
      int maxSelected = 1; // Default max selected

      // Check if the available items are empty
      if (displayedItems.isEmpty) {
        // If subtype is "StandardNormal", "SpectralJumbo" or "BuffoonNormal"
        // set the max choices and displayed items accordingly
        switch (subtype) {
          // Standard Normal
          case 3:
            maxChoices = 3;
            displayedItems = _getRandomItems(availableItems, maxChoices);
            maxSelected = 3;
            break;
          // Spectral Jumbo
          case 2:
            maxChoices = 2;
            displayedItems = _getRandomItems(availableItems, maxChoices);
            maxSelected = 1;
            break;
          // Buffoon Normal
          case 1:
            maxChoices = 2;
            displayedItems = _getRandomItems(availableItems, maxChoices);
            maxSelected = 1;
            break;
          default:
            displayedItems = _getRandomItems(availableItems, 1);
        }
      }

      // Set the title and subtitle based on the subtype
      switch (subtype) {
        // Standard Normal
        case 3:
          title = "Standard Pack";
          subtitle = "Choose up to 3";
          break;
        // Spectral Jumbo
        case 2:
          title = "Voucher Pack";
          subtitle = "SPECTRAL";
          break;
        // Buffoon Normal
        case 1:
          title = "Mystery Pack";
          subtitle = "BUFFOON";
          break;
        default:
          title = "Unknown Pack";
          subtitle = "";
      }
      // Set the content of the dialog based on the subtype
      content = StatefulBuilder(
        builder: (context, setState) {
          return _buildSelectableRow(displayedItems, selectedIndexes, (index) {
            setState(() {
              if (selectedIndexes.contains(index)) {
                selectedIndexes.remove(index);
                debugPrint("Removed index: $index");
              } else if (selectedIndexes.length < maxSelected) {
                selectedIndexes.add(index);
                debugPrint("Added index: $index");
              }
            });
          }, maxChoices: maxChoices);
        },
      );
      // Show the dialog with the custom content
      // The dialog will be closed when the user selects an item
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
        child: Container(
          width: (150 * displayedItems.length).toDouble(),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3454),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.blue, blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[200],
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 5),
              content,
              const SizedBox(height: 5),

              // Display the selected items
              ElevatedButton(
                onPressed: () {
                  if (selectedIndexes.isNotEmpty) {
                    Navigator.of(
                      context,
                    ).pop(displayedItems[selectedIndexes.first]);
                  }
                },
                child: Text(
                  maxChoices > 2 ? "Choose" : "Choose 1",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Display a dialog where you can select among the users on the lobby who to throw the consumable used
Future<void> showUseConsumableDialog(
  BuildContext context,
  PurchasableItemInfo consumable,
  int numMaxSelected,
  GlobalKey<State<StatefulWidget>> key,
  List<Map<String, dynamic>> lobbyUsers,
  void Function() onUse,
) async {
  int numSelected = 0;

  bool onTap() {
    bool tapped = numSelected < numMaxSelected;
    if (tapped) numSelected++;
    return tapped;
  }

  void onTapAgain() {
    numSelected--;
  }

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      debugPrint("${lobbyUsers.length}");
      return Dialog(
        backgroundColor: const Color(0xFF2C2F3D),
        child: ConstrainedBox(
          // Box dimensions
          constraints: const BoxConstraints(
            minWidth: 300,
            maxWidth: 400,
            minHeight: 200,
            maxHeight: 300,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Column(
                  children: [
                    SizedBox(height: 35),
                    // Name of the consumable chosen
                    Text(
                      "Nombre del voucher",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 40),
                    // Appearence of the consumable
                    Transform.scale(
                      scale: 2,
                      child: Joker(
                        purchasableItemInfo: consumable,
                        keyWidget: key,
                      ),
                    ),
                    SizedBox(height: 30),
                    // Buttons
                    Row(
                      children: [
                        // Use consumable button
                        ElevatedButton(
                          onPressed: () {
                            if (numSelected > 0) {
                              onUse();
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0ea5e9),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                16,
                              ), // Smooth the border shape
                            ),
                            minimumSize: const Size(50, 40),
                          ),
                          child: const Text(
                            "Use",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        SizedBox(width: 6),

                        // Close dialog button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFd41976),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                16,
                              ), // Smooth the border shape
                            ),
                            minimumSize: const Size(50, 40),
                          ),
                          child: const Text(
                            "Close",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(width: 20),

                // List of players to throw the consumable's action
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Choose up to 3",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),

                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent:
                                    100, //width of the player's box
                                crossAxisSpacing: 10,
                                mainAxisExtent: 70, //height of the player's box
                                mainAxisSpacing: 10,
                                childAspectRatio: 3,
                              ),
                          itemCount: lobbyUsers.length,
                          itemBuilder: (context, index) {
                            final player = lobbyUsers[index];
                            return PlayerBoxConsumables(
                              playerName: player['username'],
                              playerIcon: player['avatarImage'],
                              onTap: onTap,
                              onTapAgain: onTapAgain,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Dialog to display wheter you won or lost the game
Future<void> useWinLoseDialog(BuildContext context, bool winner) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF2A2A3B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // jokerHat image and background
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFD700),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Image.asset('images/jokerHat.png', height: 60),
                ),
                SizedBox(height: 5),
                // dependent text wheter you lose or win
                Text(
                  winner ? "YOU WIN!" : "YOU LOSE 😿",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 5),
                // Dont know what is this (why points?)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF3C3C4F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text("Points", style: TextStyle(color: Colors.white70)),
                      Text(
                        "90000",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                // Home button to return to home menu
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: const HomeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text("Home", style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Buils a selectable row of cards
Widget _buildSelectableRow(
  List<PurchasableItemInfo> items,
  List<int> selectedIndexes,
  Function(int) onSelect, {
  int maxChoices = 1,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children:
        items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = selectedIndexes.contains(index);
          // Check if the item is disabled
          final isDisabled =
              !isSelected && selectedIndexes.length >= maxChoices;

          return GestureDetector(
            onTap: () {
              if (!isDisabled) {
                // Only allow selection if not disabled
                onSelect(index);
              }
            },
            child: _buildCard(
              item.type,
              item.subtype,
              item.cardName,
              isSelected: isSelected,
              isDisabled: isDisabled,
            ),
          );
        }).toList(),
  );
}

/// Builds a single card widget, either a playing card or an image-based item
Widget _buildCard(
  String type,
  int assetName,
  String cardName, {
  bool isSelected = false,
  bool isDisabled = false,
}) {
  return Container(
    margin: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        // Shadow effect depends on the selection/disabled status
        if (isSelected) ...[
          BoxShadow(color: Colors.yellow, blurRadius: 15, spreadRadius: 2),
          BoxShadow(color: Colors.blue, blurRadius: 10, spreadRadius: 1),
        ] else if (isDisabled) ...[
          BoxShadow(color: Colors.grey, blurRadius: 5),
        ] else ...[
          BoxShadow(color: Colors.blue, blurRadius: 8, spreadRadius: 1),
        ],
      ],
    ),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isSelected ? 100 : 90,
      height: isSelected ? 130 : 120,
      decoration: BoxDecoration(
        color: isDisabled ? Colors.blue[900]! : Colors.blue[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isSelected
                  ? Colors.yellow
                  : isDisabled
                  ? Colors.grey
                  : Colors.blue[200]!,
          width: isSelected ? 3 : 2,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Opacity(
              opacity: isDisabled ? 0.6 : 1.0,
              child:
                  type == 'card'
                      // If the item is a card, build a card widget
                      ? buildCard(getSelectableCardFromAssetName(cardName))
                      // Otherwise, load the image from assets
                      : Image.asset(
                        getImagePathBySubtype(assetName, type),
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, color: Colors.red);
                        },
                      ),
            ),
          ),

          if (isSelected)
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.black),
              ),
            ),
        ],
      ),
    ),
  );
}

/// Picks a random subset of available items (up to maxChoices)
List<PurchasableItemInfo> _getRandomItems(
  List<PurchasableItemInfo> availableItems,
  int maxChoices,
) {
  final random = Random();
  // If there are fewer available items than maxChoices, return all of them
  int itemsToSelect = min(maxChoices, availableItems.length);
  return List<PurchasableItemInfo>.generate(
    itemsToSelect,
    (index) => availableItems[random.nextInt(availableItems.length)],
  );
}

/// Returns the image path based on the item's subtype
String getImagePathBySubtype(int subtype, String type) {
  switch (type) {
    case "joker":
      return JokerState().getJokerImageBySubtype(subtype);
    case "consumable":
      return JokerState().getConsumableImageBySubtype(subtype);
    case "package":
      return JokerState().getPackageImageBySubtype(subtype);
    default:
      return "images/consumables/death.png";
  }
}

/// Converts an asset name into a SelectableCard widget
SelectableCard getSelectableCardFromAssetName(String assetName) {
  final card = parseCardCode(assetName);
  return SelectableCard(
    card: card,
    overlay: 0,
    isNew: false,
    isDiscarding: false,
    isSelected: false,
    rank: '',
    suit: '',
  );
}

/// Parses a card code string into a PlayingCard object
PlayingCard parseCardCode(String code) {
  final rankChar = code.substring(0, code.length - 1);
  final suitChar = code[code.length - 1];

  // Determine suit from last character
  Suit suit;
  switch (suitChar.toUpperCase()) {
    case 'H':
      suit = Suit.hearts;
      break;
    case 'D':
      suit = Suit.diamonds;
      break;
    case 'S':
      suit = Suit.spades;
      break;
    case 'C':
      suit = Suit.clubs;
      break;
    default:
      throw Exception("Invalid suit");
  }

  // Determine card value from first part of string
  CardValue value;
  switch (rankChar) {
    case 'A':
      value = CardValue.ace;
    case 'K':
      value = CardValue.king;
    case 'Q':
      value = CardValue.queen;
    case 'J':
      value = CardValue.jack;
    case '2':
      value = CardValue.two;
    case '3':
      value = CardValue.three;
    case '4':
      value = CardValue.four;
    case '5':
      value = CardValue.five;
    case '6':
      value = CardValue.six;
    case '7':
      value = CardValue.seven;
    case '8':
      value = CardValue.eight;
    case '9':
      value = CardValue.nine;
    case '10':
      value = CardValue.ten;
    default:
      throw Exception(
        "Invalid rank: $rankChar",
      ); // Throw an exception if invalid rank
  }
  return PlayingCard(suit, value);
}
