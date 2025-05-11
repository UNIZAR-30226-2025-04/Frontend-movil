import 'package:flutter/material.dart';

/// A widget that represents the background of the game.
class GameBackgroundWidget extends StatelessWidget {
  final Widget child;

  const GameBackgroundWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/fondo_juego.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
