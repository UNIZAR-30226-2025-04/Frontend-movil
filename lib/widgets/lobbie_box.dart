import 'package:flutter/material.dart';
import 'package:nogler/data/api/party_api.dart';
import 'package:nogler/screens/lobby/lobby_screen.dart';
import 'package:nogler/widgets/build_avatar_image.dart';
import 'package:page_transition/page_transition.dart';

/// Widget to show the information of a public lobby in the JOIN LOBBY screen
class LobbieBox extends StatelessWidget {
  const LobbieBox({
    super.key,
    required this.playerName,
    required this.playerIcon,
    required this.lobbyOcupation,
    required this.lobbyCode,
  });

  final String playerName;
  final int playerIcon;
  final int lobbyOcupation;
  final String lobbyCode;

  // Variable t
  static bool colorSwap = true;

  @override
  Widget build(BuildContext context) {
    colorSwap = !colorSwap;
    return LayoutBuilder(
      builder: (context, constraints) {
        //final boxHeight = 50;
        final boxWidth = 100;
        return Container(
          width: 100,
          height: 55,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
            color:
                colorSwap
                    ? Colors.indigo
                    : const Color.fromARGB(255, 45, 58, 134),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  //make some space between
                  SizedBox(width: boxWidth * 0.15),

                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: buildAvatarImage(playerIcon),
                  ),
                  //make some space between
                  SizedBox(width: boxWidth * 0.15),

                  //Name of the host of the lobby
                  Text(
                    playerName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    onPressed: () async {
                      final public = await joinLobby(lobbyCode);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: LobbyScreen(
                              hostName: playerName,
                              hostAvatar: playerIcon,
                              lobbyState: !public,
                              lobbyCode: lobbyCode,
                            ),
                          ),
                        );
                      }
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
