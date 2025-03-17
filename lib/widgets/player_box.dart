import 'package:flutter/material.dart';

class PlayerBox extends StatelessWidget {
  const PlayerBox({
    super.key,
    required this.playerName,
    required this.playerIcon,
    required this.isHost,
  });

  final String playerName;
  final int playerIcon;
  final bool isHost;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        //TODO, medidas de la caja con constraints??
        final boxHeight = 50;
        final boxWidth = 50;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.black, width: 2),
            //If its the host in another color
            color: isHost ? Colors.red : Colors.blueAccent,
          ),
          child: Column(
            children: [
              //make some space between
              SizedBox(height: boxHeight * 0.1),
              //Icon iamge of the player as a Row
              Row(
                children: [
                  //make some space between
                  SizedBox(width: boxWidth * 1.28),
                  _buildAvatarImage(playerIcon - 1),
                ],
              ),
              //make some space between
              SizedBox(height: boxHeight * 0.15),
              //players name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isHost)
                    Icon(
                      Icons.star_border,
                      color: Colors.yellow,
                    ), //TODO, cambiar el icono con una corona, pero me hace gracia y se queda como una embarazada
                  Text(
                    playerName,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              //make some space between
              SizedBox(height: boxHeight * 0.1),
            ],
          ),
        );
      },
    );
  }
}

//copiada de profile_screen de momento
//TODO, hacerlo de otra forma cuando tengamos la base de datos
Widget _buildAvatarImage(int iconId) {
  final List<String> avatarPaths = [
    'images/pixelHeart.png',
    'images/pixelPica.png',
    'images/pixelDiamond.png',
    'images/pixelTrebol.png',
    'images/pixelSoyi.png',
    'images/pixelBrat.png',
    'images/pixelSinoc.png',
    'images/pixelBarb.png',
    'images/pixelBard.png',
  ];

    // Check if the iconId exceeds the size of the list or is negative, if so, default to index 0
  if (iconId >= avatarPaths.length || iconId < 0) {
    iconId = 0; // Default to the first avatar if the id exceeds the list size
  }
  
  return Image.asset(
    avatarPaths[iconId],
    height: 50,
    width: 50,
    errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 36),
  );
}
