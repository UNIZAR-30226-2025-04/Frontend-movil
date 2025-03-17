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
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
            color: Colors.indigo,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  //make some space between
                  SizedBox(width: boxWidth * 0.15),

                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: buildAvatarImage(playerIcon - 1),
                  ),
                  //make some space between
                  SizedBox(width: boxWidth * 0.15),

                  //Name of the host of the lobby
                  Text(
                    playerName,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              //Number of people currently in a lobby
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (lobbyOcupation == 8) ? Colors.red : Colors.green,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // Button rounded edges
                        side: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ), // Black border
                      ),
                    ),
                    onPressed: () {
                      //TODO, hacer la funcionalidad
                      // Action to join the lobby
                    },
                    child: Text("JOIN $lobbyOcupation/8"),
                  ),
                  //make some space between
                  SizedBox(width: boxWidth * 0.15),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
