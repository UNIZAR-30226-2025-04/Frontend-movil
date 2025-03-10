import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nogler/widgets/build_avatar_image.dart';

///Widget to show the information of a public lobby in the JOIN LOBBY screen
class LobbieBox extends StatelessWidget {
  const LobbieBox({
    super.key,
    required this.playerName,
    required this.playerIcon,
    required this.lobbyOcupation,
  });

  final String playerName;
  final int playerIcon;
  final int lobbyOcupation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        //final boxHeight = 50;
        final boxWidth = 100;
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Row(
            children: [
              //make some space between
              SizedBox(width: boxWidth * 0.1),

              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: buildAvatarImage(playerIcon),
              ),
              //make some space between
              SizedBox(width: boxWidth * 0.1),

              //Name of the host of the lobby
              Text(
                playerName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              //make some space between
              SizedBox(width: boxWidth * 1),

              //Number of people currently in a lobby
              Text(
                "JOIN $lobbyOcupation/8",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
