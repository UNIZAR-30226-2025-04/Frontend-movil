import 'package:flutter/material.dart';

/// A widget that represents a background image.
class BackgroundWidget extends StatelessWidget {
  final Widget child;

  const BackgroundWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
