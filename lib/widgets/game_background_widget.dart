import 'package:flutter/material.dart';

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
