import 'package:flutter/material.dart';
import 'package:nogler/dialogs/game_dialogs.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
import 'package:nogler/widgets/in_game/consumable_fase/consumable_fase_widget.dart';
import 'package:nogler/widgets/in_game/consumable_fase/use_consumable_widget.dart';
import 'package:nogler/widgets/in_game/joker_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/buy_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/sell_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_fase_widget.dart';
import 'package:nogler/widgets/in_game/shop_fase/shop_widget.dart';

/// A sidebar widget displaying game-related information such as the current round,
/// active consumables, and various game statistics.
class Sidebar extends StatefulWidget {
  const Sidebar({
    super.key,
    required this.shopWidgetKey,
    required this.buyWidgetKey,
    required this.useConsumableWidgetKey,
    required this.ownedConsumableCardsKey,
    required this.usedConsumableCardsKey,
    required this.shopFaseWidgetKey,
    required this.consumableFaseWidgetKey,
    required this.sellWidgetKey,
    required this.consumableOwned,
    required this.onAddConsumableOwned,
    required this.onRemoveConsumableOwned,
    required this.onRemoveAllConsumableOwned,
    required this.consumableUsed,
    required this.onAddConsumableUsed,
    required this.onRemoveConsumableUsed,
    required this.round,
    required this.discardingCards,
    required this.playingCards,
    required this.currentFase,
    required this.isShopPhase,
    required this.score,
    required this.redScore,
    required this.blueScore,
    required this.handType,
    required this.gold,
    required this.currentPot,
    required this.blind,
    required this.maxRounds,
  });

  final GlobalKey<ShopWidgetState> shopWidgetKey;
  final GlobalKey<BuyWidgetState> buyWidgetKey;
  final GlobalKey<UseConsumableWidgetState> useConsumableWidgetKey;
  final GlobalKey<OwnedConsumableCardsState> ownedConsumableCardsKey;
  final GlobalKey<UsedConsumableCardsState> usedConsumableCardsKey;
  final GlobalKey<ShopFaseWidgetState> shopFaseWidgetKey;
  final GlobalKey<ConsumableFaseWidgetState> consumableFaseWidgetKey;
  final GlobalKey<SellWidgetState> sellWidgetKey;
  final List<PurchasableItemInfo> consumableOwned;
  final Function(PurchasableItemInfo)? onAddConsumableOwned;
  final Function(PurchasableItemInfo)? onRemoveConsumableOwned;
  final void Function() onRemoveAllConsumableOwned;
  final List<PurchasableItemInfo> consumableUsed;
  final Function(PurchasableItemInfo)? onAddConsumableUsed;
  final Function(PurchasableItemInfo)? onRemoveConsumableUsed;
  final int round;
  final int discardingCards;
  final int playingCards;
  final String currentFase;
  final bool isShopPhase;
  final int score;
  final int redScore;
  final int blueScore;
  final int handType;
  final int gold;
  final int currentPot;
  final int blind;
  final int maxRounds;

  @override
  SidebarState createState() => SidebarState();
}

class SidebarState extends State<Sidebar> {
  final Map<String, dynamic> phaseTextInfo = {
    'chooseBlindFase': "CHOOSE BLIND",
    'gameFase': "ROUND",
    'shopFase': "SHOP",
    'consumableFase': "CONSUMABLES",
  };

  final Map<String, dynamic> phaseIconInfo = {
    'chooseBlindFase': Icons.blind,
    'gameFase': Icons.casino,
    'shopFase': Icons.shopping_cart,
    'consumableFase': Icons.card_giftcard,
  };

  final Map<String, dynamic> phaseColorInfo = {
    'chooseBlindFase': Colors.purple[800],
    'gameFase': Colors.purple[800],
    'shopFase': Colors.blue[800],
    'consumableFase': Colors.blue[800],
  };

  /// Returns the name of the level 1 hand based on its position (1 to 13).
  String getHandTypeName(int number) {
    // List of all level 1 hand names in order.
    final List<String> rankNames = [
      'Flush five',
      'Flush house',
      'Five of a kind',
      'Royal flush',
      'Straight flush',
      'Four of a kind',
      'Full house',
      'Flush',
      'Straight',
      'Three of a kind',
      'Two pair',
      'One pair',
      'High card',
    ];

    // If the input number is between 1 and 13, return the corresponding hand name.
    if (number >= 1 && number <= 13) {
      return 'lvl.1 ${rankNames[number - 1]}';
    } else {
      // Return an error message for out-of-range input.
      return 'Number out of range (1-13)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: EdgeInsets.all(10),
      color: const Color(0xFF2C3454),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /// Displays the current round number.
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 24,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                // Get the color dependent on which fase is ongoing
                color: phaseColorInfo[widget.currentFase],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display the fase dependent icon
                  Icon(
                    phaseIconInfo[widget.currentFase],
                    size: 16,
                    color: Colors.white,
                  ),

                  SizedBox(width: 4),
                  // Display the label dependent on the ongoing phase
                  // If the fase is game fase we display a round dependent label
                  Text(
                    widget.currentFase == "gameFase"
                        ? "ROUND ${widget.round}/${widget.maxRounds}"
                        : phaseTextInfo[widget.currentFase],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Displays modification cards for the game.
          _buildModCards(),
          SizedBox(height: 4),

          /// Displays overall game statistics.
          _buildGameStats(
            widget.discardingCards.toString(),
            widget.playingCards.toString(),
            widget.score.toString(),
            widget.blueScore.toString(),
            widget.redScore.toString(),
            getHandTypeName(widget.handType),
            widget.gold.toString(),
            widget.currentPot.toString(),
            widget.blind.toString(),
          ),
        ],
      ),
    );
  }

  /// Builds a horizontal list of modification cards.
  Widget _buildModCards() {
    return Stack(
      children: [
        Visibility(
          visible: widget.currentFase == "shopFase",
          child: OwnedConsumableCards(
            key: widget.ownedConsumableCardsKey,
            consumableOwned: widget.consumableOwned,
            onAddConsumableOwned: widget.onAddConsumableOwned,
            onRemoveConsumableOwned: widget.onRemoveConsumableOwned,
            onRemoveAllConsumableOwned: widget.onRemoveAllConsumableOwned,
            shopFaseWidgetKey: widget.shopFaseWidgetKey,
            consumableFaseWidgetKey: widget.consumableFaseWidgetKey,
            shopWidgetKey: widget.shopWidgetKey,
            buyWidgetKey: widget.buyWidgetKey,
            sellWidgetKey: widget.sellWidgetKey,
          ),
        ),
        Visibility(
          visible: widget.currentFase != "shopFase",
          child: UsedConsuambleCards(
            key: widget.usedConsumableCardsKey,
            consumableUsed: widget.consumableUsed,
            onAddConsumableUsed: widget.onAddConsumableUsed,
            onRemoveConsumableUsed: widget.onRemoveConsumableUsed,
            consumableFaseWidgetKey: widget.consumableFaseWidgetKey,
            useConsumableWidgetKey: widget.useConsumableWidgetKey,
          ),
        ),
      ],
    );
    /*
    widget.currentFase == "shopFase"
        ? OwnedConsumableCards(
          key: widget.ownedConsumableCardsKey,
          shopFaseWidgetKey: widget.shopFaseWidgetKey,
          consumableFaseWidgetKey: widget.consumableFaseWidgetKey,
          shopWidgetKey: widget.shopWidgetKey,
          buyWidgetKey: widget.buyWidgetKey,
          sellWidgetKey: widget.sellWidgetKey,
        )
        : UsedConsuambleCards(
          key: widget.usedConsumableCardsKey,
          consumableFaseWidgetKey: widget.consumableFaseWidgetKey,
          useConsumableWidgetKey: widget.useConsumableWidgetKey,
        );
        */
  }

  /// Builds a section displaying game statistics such as round score and player stats.
  Widget _buildGameStats(
    String remainingCards,
    String playingCards,
    String score,
    String blueScore,
    String redScore,
    String handType,
    String gold,
    String pot,
    String blind,
  ) {
    return Column(
      children: [
        // Displays the round score
        Container(
          padding: EdgeInsets.all(5),
          decoration: _boxDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Round \nScore",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10),
              _buildAnimatedScore(score, blind), // Animated counter
            ],
          ),
        ),

        SizedBox(height: 4),

        // Displays game multipliers and levels.
        GestureDetector(
          onTap: () => showHandTypes(context),
          child: Container(
            height: 68,
            padding: EdgeInsets.all(8),
            decoration: _boxDecoration(),
            child: Column(
              children: [
                Text(
                  handType,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatBox(blueScore, const Color(0xFF0ea5e9)),
                    SizedBox(width: 5),
                    Text(
                      "X",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 2),
                    _buildStatBox(redScore, const Color(0xFFd41976)),
                  ],
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 4),

        // Displays additional player statistics
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLabelAndValue(
                  "Hands",
                  playingCards,
                  const Color(0xFF9fdbf6),
                ),
                SizedBox(width: 10),
                _buildLabelAndValue(
                  "Discards",
                  remainingCards,
                  const Color(0xFFeea3c8),
                ),
              ],
            ),
            SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLabelAndValue("Pot", "$pot€", const Color(0xFFffffff)),
                SizedBox(width: 10),
                _buildLabelAndValue("Money", "$gold€", const Color(0xFFf7e19c)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the animated round score counter with a styled container
  Widget _buildAnimatedScore(String score, String blind) {
    int parsedScore = int.tryParse(score) ?? 0;
    int parsedBlind = int.tryParse(blind) ?? 0;
    int currrentScore = parsedBlind - parsedScore;
    bool isReached = false;
    if (parsedScore > 0) {
      isReached = parsedScore >= parsedBlind;
    }

    // If the score is higher or equal than the blind, display "Reached"
    if (isReached) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF2C3454),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Text(
          "Reached",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    // Otherwise, animate the score counting up from 0 to the actual score
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: currrentScore),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutExpo,
      builder: (context, value, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3454),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  /// Builds a stat box with animated score.
  Widget _buildStatBox(String value, Color color) {
    final int parsedValue = int.tryParse(value) ?? 0;

    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: parsedValue),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutExpo,
      builder: (context, animatedValue, child) {
        return Container(
          width: 60,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Center(
            child: Text(
              animatedValue.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Creates a styled box decoration for UI components.
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: const Color(0xFF495a8f),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.black, width: 2),
    );
  }

  /// Builds a labeled value box for game statistics.
  Widget _buildLabelAndValue(String label, String value, Color color) {
    return Container(
      width: 85,
      height: 50,
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: const Color(0xFF495a8f),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          Container(
            width: 65,
            height: 23,
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3454),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
