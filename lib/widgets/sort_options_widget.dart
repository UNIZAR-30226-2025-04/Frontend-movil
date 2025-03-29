import 'package:flutter/material.dart';

/// A widget that provides sorting options for the player's hand.
/// Users can sort by "Rank" or "Suit" using the available buttons.
class SortOptions extends StatelessWidget {
  const SortOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 55,
      padding: EdgeInsets.all(10), // Padding inside the container
      decoration: BoxDecoration(
        color: Colors.white, // White background
        borderRadius: BorderRadius.circular(10), // Rounded borders
        border: Border.all(color: Colors.black, width: 2), // Black border
      ),
      child: Column(
        children: [
          // Title "Sort hand"
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sort hand",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 2),

          // Row containing "Rank" and "Suit" buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSortButton("Rank"),
              SizedBox(width: 5), // Space between buttons
              _buildSortButton("Suit"),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a sorting button with a given title.
  Widget _buildSortButton(String title) {
    return SizedBox(
      width: 40, // Button width
      height: 15, // Button height
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // White button background
          foregroundColor: Colors.black, // Black text color
          padding: EdgeInsets.all(1), // Padding inside button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5), // Rounded corners
            side: BorderSide(color: Colors.black, width: 2), // Black border
          ),
        ),
        onPressed: () {},
        child: Text(
          title,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ), // Text size adjustment
        ),
      ),
    );
  }
}
