// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';

class PlayerBoxConsumables extends StatefulWidget {
  const PlayerBoxConsumables({
    super.key,
    required this.playerName,
    required this.playerIcon,
    required this.onTap,
    required this.onTapAgain,
  });

  final String playerName;
  final int playerIcon;
  final bool Function(String) onTap;
  final void Function(String) onTapAgain;

  @override
  PlayerBoxConsumablesState createState() => PlayerBoxConsumablesState();
}

class PlayerBoxConsumablesState extends State<PlayerBoxConsumables>
    with SingleTickerProviderStateMixin {
  // Animation parameters
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _sizeAnimation = Tween<double>(
      begin: 50.0,
      end: 85.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation = ColorTween(
      begin: Colors.blueAccent,
      end: Colors.greenAccent,
    ).animate(_controller);
  }

  void _toggleAnimation() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            if (_colorAnimation.value == Colors.blueAccent) {
              if (widget.onTap(widget.playerName)) {
                _toggleAnimation();
              }
            } else {
              widget.onTapAgain(widget.playerName);
              _toggleAnimation();
            }
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                height: _sizeAnimation.value,
                width: _sizeAnimation.value,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: _colorAnimation.value,
                ),
                child: Column(
                  children: [
                    //make some space between
                    SizedBox(height: 7),
                    Row(
                      children: [
                        //make some space between
                        SizedBox(width: 30),
                        _buildAvatarImage(widget.playerIcon),
                      ],
                    ),
                    //make some space between
                    SizedBox(height: 2),

                    // Player name
                    Text(
                      (widget.playerName.length > 8)
                          ? "${widget.playerName.substring(0, 7)}..."
                          : widget.playerName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

Widget _buildAvatarImage(int iconId) {
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

  return Image.asset(
    avatarPaths[iconId],
    height: 35,
    width: 35,
    errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 36),
  );
}
