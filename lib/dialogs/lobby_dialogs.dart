import 'package:flutter/material.dart';
import 'package:nogler/data/api/invitation_api.dart';
import 'package:nogler/widgets/build_avatar_image.dart';

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
