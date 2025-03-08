import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nogler/screens/home/home_screen.dart';
import 'package:nogler/widgets/background_widget.dart';
import 'package:nogler/widgets/player_box.dart';
import 'package:page_transition/page_transition.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreen();
}

class _LobbyScreen extends State<LobbyScreen> {
  List<String> lobbyUsers = [
    "Jogue",
    "Emilliano",
    "Nicock",
    "YagoAndTheYagos",
    "Victor Bodrios",
    "Ruben",
    "Jota",
    "Josemi",
  ];

  String publicPrivateButton = "Public";
  String lobbyCode = "1234";

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          body: BackgroundWidget(
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Add some space between
                    SizedBox(width: 15),

                    //Title of page, lobby
                    Text(
                      'LOBBY',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    //Add some space between
                    SizedBox(width: 15),

                    //Number of participants
                    Text(
                      '8 / 8',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    //Add some space between
                    SizedBox(width: 20),

                    //TODO, boton de public para poder cambiar entre private y public
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        //TODO, que implica que sean privadas y publicas -> cambiar especificaciones lobby en base de datos, etc
                        setState(() {
                          if (publicPrivateButton == 'Public') {
                            publicPrivateButton = 'Private';
                          } else {
                            publicPrivateButton = 'Public';
                          }
                        });
                      },
                      child: Text(
                        publicPrivateButton,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    //Add some space between
                    SizedBox(width: 25),

                    //Code of the lobby
                    Text(
                      'Code: $lobbyCode',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    //Add some space between
                    SizedBox(width: 25),

                    //Copy button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                      //copies on clipboard the lobbies code
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: lobbyCode));
                      },
                      child: Text(
                        "Copy",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    //Add some space between
                    SizedBox(width: 25),

                    //Share button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        "Share",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    //Add some space between
                    SizedBox(width: 110),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {},
                      child: Icon(Icons.chat_bubble, color: Colors.black),
                    ),
                  ],
                ),

                //User distribution
                Expanded(
                  child: Align(
                    alignment: const Alignment(0, -0.5),
                    child: Stack(
                      fit: StackFit.loose,
                      alignment: Alignment.topLeft,
                      children: [
                        GridView.builder(
                          shrinkWrap: true,

                          padding: EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 15,
                            bottom: 0,
                          ),

                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent:
                                    200, //width of the player's box
                                crossAxisSpacing: 12,
                                mainAxisExtent:
                                    100, //height of the player's box
                                mainAxisSpacing: 12,
                                childAspectRatio: 3,
                              ),
                          itemCount: lobbyUsers.length,
                          itemBuilder: (context, index) {
                            return PlayerBox(
                              playerName: lobbyUsers[index],
                              playerIcon: 1, //TODO, conexion con base de datos
                              isHost:
                                  lobbyUsers[index] ==
                                  'Jogue', //TODO, conexion con base de datos
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                //Leave lobby button
                Row(
                  //button at the end of the row
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: const HomeScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Leave',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
