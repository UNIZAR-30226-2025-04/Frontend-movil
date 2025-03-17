import 'package:flutter/material.dart';
import 'package:nogler/widgets/build_avatar_image.dart';

/// Function to show the list of game invitations
Future<void> showPartyList(BuildContext context) async {
  // Example list of invited players with avatars
  List<Map<String, dynamic>> lobbyUsers = [
    {"username": "Jogue", "icon": 0},
    {"username": "Emilliano", "icon": 1},
    {"username": "Nicock", "icon": 2},
    {"username": "YagoAndTheYagos", "icon": 3},
    {"username": "Victor Bodrios", "icon": 4},
    {"username": "Ruben", "icon": 5},
    {"username": "Jota", "icon": 6},
    {"username": "Josemi", "icon": 7},
  ];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Rounded pop-up border
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
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
                    child: ListView.builder(
                      itemCount: lobbyUsers.length, // Number of users
                      itemBuilder: (context, index) {
                        String username = lobbyUsers[index]['username'];
                        int iconId = lobbyUsers[index]['icon'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                10,
                              ), // Rounded borders
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ), // Black border
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    // Remove user button (X)
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        // Remove this user from the list
                                        setState(() {
                                          lobbyUsers.removeAt(index);
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
                            ),
                          ),
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
