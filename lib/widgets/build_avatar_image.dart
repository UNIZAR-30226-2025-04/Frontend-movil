import 'package:flutter/material.dart';

/// **Displays the correct avatar image based on the icon ID**
/// - Uses an integer index to select an avatar from the available images.
Widget buildAvatarImage(int iconId) {
  iconId = iconId;
  final List<String> avatarPaths = [
    '', // index 0 left void in order to have same index in fronted web and mobile
    'images/pixelHeart.png',
    'images/pixelPica.png',
    'images/pixelDiamond.png',
    'images/pixelTrebol.png',
    'images/pixelSinoc.png',
    'images/pixelSoyi.png',
    'images/pixelBrat.png',
    'images/pixelBarb.png',
    'images/pixelBard.png',
  ];
  // Check if the iconId exceeds the size of the list or is negative, if so, default to index 0
  if (iconId >= avatarPaths.length || iconId < 0) {
    iconId = 1; // Default to the first avatar if the id exceeds the list size
  }

  return ClipOval(
    // Clip the image to fit in a circular shape
    child: Image.asset(
      avatarPaths[iconId], // Display the avatar corresponding to the iconId
      //width: 150.0, // Set the width of the image to fit inside the CircleAvatar
      //height:
      //    150.0, // Set the height of the image to fit inside the CircleAvatar
      fit: BoxFit.cover, // Ensure the image covers the CircleAvatar area
      errorBuilder:
          (_, __, ___) => const Icon(
            Icons.person,
            size: 36,
          ), // Default icon if image fails to load
    ),
  );
}
