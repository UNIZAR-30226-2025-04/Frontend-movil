import 'package:flutter/material.dart';

class AppStyles {
  // Colors
  static const Color primaryColor = Color(0xFF3A86FF);
  static const Color secondaryColor = Color(0xFFFF006E);
  static const Color accentColor = Color(0xFF8338EC);
  static const Color backgroundColor = Colors.white;
  static const Color errorColor = Colors.red;
  static const Color successColor = Color(0xFF3DD598);
  
  // Text Styles
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  
  // Button Styles
  static final ButtonStyle cancelButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: errorColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

