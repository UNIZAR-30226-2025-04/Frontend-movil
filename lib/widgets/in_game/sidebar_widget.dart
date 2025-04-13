import 'package:flutter/material.dart';
import 'package:nogler/widgets/in_game/consumable_cards_widget.dart';
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
    required this.consumableCardsKey,
    required this.shopFaseWidgetKey,
    required this.sellWidgetKey,
  });

  final GlobalKey<ShopWidgetState> shopWidgetKey;
  final GlobalKey<BuyWidgetState> buyWidgetKey;
  final GlobalKey<ConsumableCardsState> consumableCardsKey;
  final GlobalKey<ShopFaseWidgetState> shopFaseWidgetKey;
  final GlobalKey<SellWidgetState> sellWidgetKey;

  @override
  SidebarState createState() => SidebarState();
}

class SidebarState extends State<Sidebar> {
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
            child: Text(
              "Round 1/10",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          /// Displays modification cards for the game.
          _buildModCards(),
          SizedBox(height: 5),

          /// Displays overall game statistics.
          _buildGameStats(),
        ],
      ),
    );
  }

  /// Builds a horizontal list of modification cards.
  Widget _buildModCards() {
    return ConsumableCards(
      key: widget.consumableCardsKey,
      shopWidgetKey: widget.shopWidgetKey,
      buyWidgetKey: widget.buyWidgetKey,
      shopFaseWidgetKey: widget.shopFaseWidgetKey,
      sellWidgetKey: widget.sellWidgetKey,
    );
  }

  /// Builds a section displaying game statistics such as round score and player stats.
  Widget _buildGameStats() {
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

              Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3454),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Text(
                  "302.24€",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 5),

        // Displays game multipliers and levels.
        Container(
          padding: EdgeInsets.all(8),
          decoration: _boxDecoration(),
          child: Column(
            children: [
              Text(
                "Full House lvl 2",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatBox("90", const Color(0xFF0ea5e9)),
                  SizedBox(width: 5),
                  Text(
                    "X",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5),
                  _buildStatBox("8", const Color(0xFFd41976)),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 5),

        // Displays additional player statistics
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLabelAndValue("Hands", "3", const Color(0xFF9fdbf6)),
                SizedBox(width: 10),
                _buildLabelAndValue("Discards", "4", const Color(0xFFeea3c8)),
              ],
            ),
            SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLabelAndValue("Pot", "5€", const Color(0xFFffffff)),
                SizedBox(width: 10),
                _buildLabelAndValue("Money", "20€", const Color(0xFFf7e19c)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a labeled value box for game statistics.
  Widget _buildStatBox(String value, Color color) {
    return Container(
      width: 60,
      height: 35,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          Container(
            width: 80,
            height: 20,
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
                    fontSize: 10,
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
