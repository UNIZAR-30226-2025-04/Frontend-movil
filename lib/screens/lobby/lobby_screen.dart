import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nogler/dialogs/lobby_dialogs.dart';
import 'package:nogler/screens/home/home_screen.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/background_widget.dart';
import 'package:nogler/widgets/chat_widget.dart';
import 'package:nogler/widgets/player_box.dart';
import 'package:page_transition/page_transition.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({
    super.key,
    required this.hostName,
    required this.hostAvatar,
    required this.lobbyState,
    required this.lobbyCode,
  });

  final String hostName;
  final int hostAvatar;
  final bool lobbyState; // true = private, false = public
  final String lobbyCode;

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

  // WebSocket
  final WebSocketClient wsClient = WebSocketClient();

  List<Map<String, dynamic>> chatMessages = [];

  String _publicPrivateButton = "Public";
  bool hasFetched = false;

  // Needed to define which Scaffold we are refering
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void addMessage(
    String username,
    int avatarImage,
    String message,
    String time,
  ) {
    setState(() {
      chatMessages.add({
        'username': username,
        'avatarImage': avatarImage,
        'message': message,
        'time': time,
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _publicPrivateButton = widget.lobbyState ? "Private" : "Public";
    wsClient.sendMessage("join_lobby", widget.lobbyCode);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          // Dont redimension page if keyboard on
          resizeToAvoidBottomInset: false,
          // Key needed to refer to the scaffold
          key: _scaffoldKey,
          // Chat drawer definition
          endDrawer: ChatWidget(
            myUsername: widget.hostName,
            myAvatarImage: widget.hostAvatar,
            lobbyCode: widget.lobbyCode,
            chatMessages: chatMessages,
            onSend: addMessage,
          ),

          body: BackgroundWidget(
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                              if (_publicPrivateButton == 'Public') {
                                _publicPrivateButton = 'Private';
                              } else {
                                _publicPrivateButton = 'Public';
                              }
                            });
                          },
                          child: Text(
                            _publicPrivateButton,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        //Add some space between
                        SizedBox(width: 25),

                        //Code of the lobby
                        Text(
                          'Code: ${widget.lobbyCode}',
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
                            await Clipboard.setData(
                              ClipboardData(text: widget.lobbyCode),
                            );
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
                          onPressed: () {
                            showInvitationLists(context, widget.lobbyCode);
                          },
                          child: Text(
                            "Share",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),

                    //Chat button
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            // Open Drawer using the key previously mentioned
                            _scaffoldKey.currentState?.openEndDrawer();
                          },
                          child: Icon(Icons.chat_bubble, color: Colors.black),
                        ),
                        //Add some space between
                        SizedBox(width: 15),
                      ],
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
                          shrinkWrap: false,

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
                            if (index == 0) {
                              return PlayerBox(
                                playerName: widget.hostName,
                                playerIcon: widget.hostAvatar,
                                isHost: true,
                                kickUser: (String playerNameKick) {},
                              );
                            } else {
                              return PlayerBox(
                                playerName: lobbyUsers[index],
                                playerIcon:
                                    1, //TODO, conexion con base de datos
                                isHost: false,
                                kickUser: (String playerNameKick) {
                                  setState(() {
                                    lobbyUsers.remove(playerNameKick);
                                  });
                                },
                              );
                            }
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
                          // Exit lobby in WebSocket
                          wsClient.sendMessage("exit_lobby", {
                            widget.lobbyCode,
                            widget.hostName,
                          });

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
