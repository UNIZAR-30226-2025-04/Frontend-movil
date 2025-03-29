import 'package:flutter/material.dart';

/// A settings button widget.
/// Displays a settings icon that can be tapped to open a settings panel.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: 80,
      child: Container(
        width: 50, // Set the panel size to 30
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          icon: Icon(Icons.settings, color: const Color.fromARGB(255, 57, 231, 136), size: 25),
          onPressed: () {},
        ),
      ),
    );
  }
}
