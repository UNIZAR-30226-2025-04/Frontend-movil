import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nogler/data/api/party_api.dart';
import 'package:nogler/screens/lobby/lobby_screen.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/build_avatar_image.dart';
import 'package:page_transition/page_transition.dart';

/// Function to show the list of game invitations
Future<void> showPartyList(BuildContext context, String myusername) async {
  List<Map<String, dynamic>> invitationsList = [];
  bool hasFetched = false; // To ensure the data is fetched only once
  bool isLoading = true; // Flag to track loading state
  final WebSocketClient wsClient =
      WebSocketClient(); // WebSocket client instance
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          if (!hasFetched) {
            hasFetched = true;
            Future.delayed(Duration.zero, () async {
              // Fetch the friends list from the API
              final data =
                  await getReceivedGameLobbyInvitations(); // Function to fetch friends
              if (context.mounted) {
                setState(() {
                  invitationsList = List.from(data);
                  isLoading =
                      false; // Set loading to false once data is fetched
                });
              }
            });
          }
          return AlertDialog(
            backgroundColor: const Color(0xFF2C3454),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Rounded pop-up border
            ),
            content: SizedBox(
              width: 550, // pop-up width
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button (X) at the top right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'X',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Title
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Most recent game invitations",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10), // Space before list
                  // Scrollable List of Users
                  Expanded(
                    child: // Show loading indicator while data is being fetched
                        isLoading
                            ? const Center(
                              child:
                                  CircularProgressIndicator(), // Show loading spinner
                            )
                            : invitationsList.isEmpty
                            ? Center(
                              child: Text(
                                'No game invitations available', // Message when no data is available
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            : ListView.builder(
                              itemCount:
                                  invitationsList.length, // Number of users
                              itemBuilder: (context, index) {
                                String username =
                                    invitationsList[index]['username'];
                                int iconId = invitationsList[index]['icon'];
                                String lobbyId =
                                    invitationsList[index]['lobby_id'];
                                int numberOfPlayers =
                                    invitationsList[index]['player_count'];
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        // Remove user button (X)
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          color: Colors.white,
                                          onPressed: () {
                                            // Remove this user from the list
                                            setState(() {
                                              deleteLobbyInvitation(
                                                lobbyId,
                                                username,
                                              );
                                              invitationsList.removeAt(index);
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 10),
                                        // Avatar image (with icon ID)
                                        CircleAvatar(
                                          child: buildAvatarImage(
                                            iconId,
                                          ), // Use custom avatar function
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          username, // Display username dynamically
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // "JOIN X/8" button
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
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
                                        final public = await joinLobby(lobbyId);

                                        // Store the code in secure storage
                                        await const FlutterSecureStorage()
                                            .write(key: 'code', value: lobbyId);
                                        // Auto-connect when screen loads
                                        await wsClient.initialize();
                                        if (context.mounted) {
                                          // Delete lobby invitation
                                          setState(() {
                                            deleteLobbyInvitation(
                                              lobbyId,
                                              username,
                                            );
                                            invitationsList.removeAt(index);
                                          });

                                          // Navigate to lobby screen
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              type: PageTransitionType.fade,
                                              child: LobbyScreen(
                                                hostName: myusername,
                                                hostAvatar: iconId,
                                                lobbyState: !public,
                                                lobbyCode: lobbyId,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        "JOIN $numberOfPlayers/8",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
