import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nogler/data/api/lobby_api.dart';
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
  List<Map<String, dynamic>> lobbyUsers = [];
  String? lobbyCreator;
  // WebSocket
  final WebSocketClient wsClient = WebSocketClient();

  List<Map<String, dynamic>> chatMessages = [];

  String _publicPrivateButton = "Public";
  bool hasFetched = false;

  // Needed to define which Scaffold we are refering
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _publicPrivateButton = widget.lobbyState ? "Private" : "Public";
    wsClient.sendMessage("join_lobby", widget.lobbyCode);
    wsClient.sendMessage("get_lobby_info", widget.lobbyCode);

    // Listen for lobby info
    wsClient.addEventListener("lobby_info", (data) {
      debugPrint("📡 Received lobby info: $data");

      final players = data['players'] as List<dynamic>;
      setState(() {
        lobbyCreator = data['creator']['username'];
        lobbyUsers =
            players.map<Map<String, dynamic>>((player) {
              return {
                'username': player['username'] ?? 'Unknown',
                'avatarImage': player['user_icon'] ?? 0,
              };
            }).toList();
      });
    });

    // Listen for when a new user joins the lobby
    wsClient.addEventListener("new_user_in_lobby", (data) {
      debugPrint("👤 New user joined: $data");

      final username = data['username'] ?? 'Unknown';

      // Check if the user is already in the lobby
      if (!lobbyUsers.any((user) => user['username'] == username)) {
        final newUser = {
          'username': username,
          'avatarImage': data['icon'] ?? 0,
        };

        setState(() {
          lobbyUsers.add(newUser);
        });
      }
    });

    // Listen for new lobby messages
    wsClient.addEventListener("new_lobby_message", (data) {
      debugPrint("🟨 Message received");
      setState(() {
        chatMessages.add({
          'username': data["username"] ?? "Unknown",
          'avatarImage': data["user_icon"] ?? 0,
          'message': data["message"] ?? "",
          'time': TimeOfDay.now().format(context),
        });
      });

      debugPrint("🟩 Total messages: ${chatMessages.length}");
    });

    // Listen for player who left the lobby
    wsClient.addEventListener("player_left", (data) {
      final username = data['username'];
      final lobbyId = data['lobby_id'];

      if (username != null && lobbyId == widget.lobbyCode) {
        setState(() {
          lobbyUsers.removeWhere((user) => user['username'] == username);
        });
      }
    });

    // Listen for kick success
    wsClient.addEventListener("kick_success", (data) {
      final kickedUser = data['kicked_user'];
      final lobbyId = data['lobby_id'];

      if (kickedUser != widget.hostName && lobbyId == widget.lobbyCode) {
        setState(() {
          lobbyUsers.removeWhere((p) => p['username'] == kickedUser);
        });
      }
    });

    // Listen for player kicked event
    wsClient.addEventListener("you_were_kicked", (data) {
      final lobbyId = data['lobby_id'];

      // Check if the kicked user is the current user
      if (lobbyId == widget.lobbyCode) {
        // Clean up WebSocket listeners
        wsClient.removeEventListener("new_lobby_message");
        wsClient.removeEventListener("lobby_info");
        wsClient.removeEventListener("new_user_in_lobby");
        wsClient.removeEventListener("kick_success");
        wsClient.removeEventListener("you_were_kicked");
        wsClient.removeEventListener("player_left");
        wsClient.removeEventListener("player_kicked");

        // Go back to home screen or show a dialog
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: const HomeScreen(),
          ),
        );
      }
    });

    // Listen for kick event
    wsClient.addEventListener("player_kicked", (data) {
      final lobbyId = data['lobby_id'];
      final kickedUser = data['kicked_user'];

      // Remove the kicked user from the lobbyUsers list
      if (kickedUser != widget.hostName && lobbyId == widget.lobbyCode) {
        setState(() {
          lobbyUsers.removeWhere((p) => p['username'] == kickedUser);
        });
      }
    });
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
                          '${lobbyUsers.length} / 8',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        //Add some space between
                        SizedBox(width: 20),

                        // Public/Private button
                        // If the user is the host, show the button to change visibility
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () async {
                            // Change the visibility of the lobby
                            if (lobbyCreator == widget.hostName) {
                              setState(() {
                                if (_publicPrivateButton == 'Public') {
                                  _publicPrivateButton = 'Private';
                                } else {
                                  _publicPrivateButton = 'Public';
                                }
                              });
                              await updateVisibilityLobby(
                                widget.lobbyCode,
                                _publicPrivateButton == 'Public'
                                    ? 'true'
                                    : 'false',
                              );
                            }
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
                            final player = lobbyUsers[index];
                            final isHost = player['username'] == lobbyCreator;
                            final iAmHost = lobbyCreator == widget.hostName;
                            return PlayerBox(
                              playerName: player['username'],
                              playerIcon: player['avatarImage'],
                              isHost: isHost,
                              iAmHost: iAmHost,
                              kickUser:
                                  iAmHost
                                      ? (String playerNameKick) {
                                        wsClient.sendMessage(
                                          "kick_from_lobby",
                                          {widget.lobbyCode, playerNameKick},
                                        );
                                      }
                                      : (_) {},
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
                  mainAxisAlignment: MainAxisAlignment.start,
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

                          // Remoeve all listeners
                          wsClient.removeEventListener("new_lobby_message");
                          wsClient.removeEventListener("lobby_info");
                          wsClient.removeEventListener("new_user_in_lobby");
                          wsClient.removeEventListener("kick_success");
                          wsClient.removeEventListener("you_were_kicked");
                          wsClient.removeEventListener("player_left");
                          wsClient.removeEventListener("player_kicked");
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

                    // Start button if the user is the host
                    lobbyCreator == widget.hostName 
                        ? Padding(
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
                              },
                              child: Text(
                                'Start',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          )
                        : Container(), // Empty container if not host
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
