import 'package:flutter/material.dart';
import 'package:nogler/data/api/party_apy.dart';
import 'package:nogler/widgets/build_avatar_image.dart';

/// Function to show the list of game invitations
Future<void> showPartyList(BuildContext context) async {
  List<Map<String, dynamic>> invitationsList = [];
  bool hasFetched = false; // To ensure the data is fetched only once
  bool isLoading = true; // Flag to track loading state

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
                        width: 35, // Square width
                        height: 35, // Square height
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ), // Black border
                          borderRadius: BorderRadius.circular(
                            5,
                          ), // Slightly rounded corners
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          iconSize: 20, // Adjust icon size inside the square
                          padding: EdgeInsets.zero, // Remove extra padding
                          constraints:
                              const BoxConstraints(), // Fit button inside the square
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                          },
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
                                  color: Colors.grey,
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

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        // Remove user button (X)
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            // Remove this user from the list
                                            setState(() {
                                              deleteLobbyInvitation(
                                                invitationsList[index]['lobby_id'],
                                                invitationsList[index]['username']
                                              );
                                              invitationsList.removeAt(index);
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 10),
                                        // Avatar image (with icon ID)
                                        CircleAvatar(
                                          child: buildAvatarImage(
                                            iconId - 1,
                                          ), // Use custom avatar function
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          username, // Display username dynamically
                                          style: const TextStyle(fontSize: 16),
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
                                      onPressed: () {
                                        // Action to join the party
                                      },
                                      child: Text("JOIN ${index + 1}/8"),
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
