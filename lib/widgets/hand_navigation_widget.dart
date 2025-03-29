import 'package:flutter/material.dart';

/// A widget that provides navigation buttons for moving through the hand of cards.
class HandNavigation extends StatelessWidget {
  const HandNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110, // Width of the container
      height: 25, // Height of the container
      decoration: BoxDecoration(
        color: Colors.white, // White background for the container
        borderRadius: BorderRadius.circular(10), // Rounded corners
        border: Border.all(
          color: Colors.black,
          width: 2,
        ), // Black border around the container
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Button for navigating to the previous card.
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.black, // Black color for the arrow
            iconSize: 10, // Icon size
            onPressed: () {},
          ),

          // Button for navigating to the next card.
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            color: Colors.black, // Black color for the arrow
            iconSize: 10, // Icon size
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
