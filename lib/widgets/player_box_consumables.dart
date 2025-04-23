import 'package:flutter/material.dart';

class PlayerBoxConsumables extends StatefulWidget {
  const PlayerBoxConsumables({
    super.key,
    required this.playerName,
    required this.playerIcon,
  });

  final String playerName;
  final int playerIcon;

  @override
  PlayerBoxConsumablesState createState() => PlayerBoxConsumablesState();
}

class PlayerBoxConsumablesState extends State<PlayerBoxConsumables> {
  Color _boxColor = Colors.blueAccent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxHeight = 50.0;
        return GestureDetector(
          onTap: () {
            setState(() {
              _boxColor =
                  _boxColor == Colors.blueAccent
                      ? Colors.greenAccent
                      : Colors.blueAccent;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: _boxColor,
            ),
            child: Column(
              children: [
                //make some space between
                SizedBox(height: boxHeight * 0.1),
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
                  widget.playerName,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                //make some space between
                SizedBox(height: boxHeight * 0.1),
              ],
            ),
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
