import 'package:flutter/material.dart';
import 'package:nogler/data/api/invitation_api.dart';
import 'package:nogler/data/api/lobby_api.dart';
import 'package:nogler/data/api/party_api.dart';
import 'package:nogler/screens/lobby/lobby_screen.dart';
import 'package:nogler/widgets/build_avatar_image.dart';
import 'package:page_transition/page_transition.dart';

Future<void> showInvitationLists(BuildContext context, String lobbyCode) async {
  List<Map<String, dynamic>> nonInvitedFriends = [];
  List<Map<String, dynamic>> invitedFriends = [];

  bool hasFetchedNonInvitedFriends = false;
  bool hasFetchedInvitedFriends = false;
  bool isLoadingNonInvitedFriends = true;
  bool isLoadingInvitedFriends = true;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Get info of non invited users
          if (!hasFetchedNonInvitedFriends) {
            hasFetchedNonInvitedFriends = true;
            Future.delayed(Duration.zero, () async {
              final data = await getAllNonInvitedFriends(lobbyCode);
              if (context.mounted) {
                setState(() {
                  nonInvitedFriends = data;
                  nonInvitedFriends = List.from(nonInvitedFriends);
                  isLoadingNonInvitedFriends = false;
                });
              }
            });
          }
          // Get info of invited users
          if (!hasFetchedInvitedFriends) {
            hasFetchedInvitedFriends = true;
            Future.delayed(Duration.zero, () async {
              final data = await getAllInvitedFriends(lobbyCode);
              if (context.mounted) {
                setState(() {
                  invitedFriends = data;
                  invitedFriends = List.from(invitedFriends);
                  isLoadingInvitedFriends = false;
                });
              }
            });
          }
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Pop up border
            ),
            title: const Text(
              "Invitations",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: 550, // pop-up width
              height: 300, // pop-up height
              child: Row(
                children: [
                  // Column of non invited friends
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Non invited friends title
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Non-invited Friends',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        // List of non invited friends
                        isLoadingNonInvitedFriends
                            ? const Center(child: CircularProgressIndicator())
                            : nonInvitedFriends.isEmpty
                            ? Center(
                              child: Text(
                                'No friends to invite',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                            : Expanded(
                              child: ListView.builder(
                                itemCount: nonInvitedFriends.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: buildAvatarImage(
                                        nonInvitedFriends[index]['icon'] - 1,
                                      ),
                                    ),
                                    title: Text(
                                      nonInvitedFriends[index]['username'],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Invite a friend
                                        IconButton(
                                          icon: Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          ),
                                          onPressed: () {
                                            sendInvitation(
                                              lobbyCode,
                                              nonInvitedFriends[index]['username'],
                                            );
                                            // Move friend to invitedFriends and delete it in nonInvitedFriends
                                            setState(() {
                                              //TODO, entiendo que esto en cuanto a integracion le falta algo,
                                              // ya que hace falta comunicar a los demas usuarios de la sala
                                              invitedFriends.add(
                                                nonInvitedFriends[index],
                                              );
                                              nonInvitedFriends.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Non invited friends title
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Invited Friends',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        isLoadingInvitedFriends
                            ? const Center(child: CircularProgressIndicator())
                            : invitedFriends.isEmpty
                            ? Center(
                              child: Text(
                                'No friends invited',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                            : Expanded(
                              child: ListView.builder(
                                itemCount: invitedFriends.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: buildAvatarImage(
                                        invitedFriends[index]['icon'] - 1,
                                      ),
                                    ),
                                    title: Text(
                                      invitedFriends[index]['username'],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Cancel invitation to friend
                                        IconButton(
                                          icon: Icon(
                                            Icons.cancel,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            deleteInvitation(
                                              lobbyCode,
                                              invitedFriends[index]['username'],
                                            );
                                            // Move friend to NonInvitedFriends and delete it in invitedFriends
                                            setState(() {
                                              //TODO, entiendo que esto en cuanto a integracion le falta algo,
                                              // ya que hace falta comunicar a los demas usuarios de la sala
                                              nonInvitedFriends.add(
                                                invitedFriends[index],
                                              );
                                              invitedFriends.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                      ],
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

/// Function to create the pop-up in home_screen in order to create a lobby
Future<void> showCreateLobbyButton(
  BuildContext context,
  String username,
  int avatar,
) async {
  bool isSwitched = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            scrollable: true, // Makes the content scrollable
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Pop up border
            ),
            //Pop-up title
            title: const Text(
              "Create a lobby",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: 300,
              height: 200,
              child: Column(
                children: [
                  //Text explaining creating the lobby
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  //Add some space between
                  SizedBox(height: 10),

                  Row(
                    children: [
                      //Add some space between
                      SizedBox(width: 10),
                      //Text private
                      Text(
                        'Private',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      //Add some space between
                      SizedBox(width: 8),

                      //Switch to select whether the lobby is private or public
                      Switch(
                        value: isSwitched,
                        onChanged: (value) {
                          setState(() {
                            isSwitched = value;
                          });
                        },
                      ),
                      //Add some space between
                      SizedBox(width: 10),

                      //Create lobby button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          createLobby((String code) async {
                            // Join the lobby created previously
                            await joinLobby(code);
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.fade,
                                  child: LobbyScreen(
                                    hostName: username,
                                    hostAvatar: avatar,
                                    lobbyState: isSwitched,
                                    lobbyCode: code,
                                  ),
                                ),
                              );
                            }
                          });
                        },
                        child: Text(
                          "Create",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  //Add some space between
                  SizedBox(height: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 120,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close the confirmation dialog
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
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
