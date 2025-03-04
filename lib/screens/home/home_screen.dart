import 'package:nogler/screens/home/friends_functions.dart';

import 'package:flutter/material.dart';
import 'package:nogler/widgets/background_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Home screen of the application
class _HomeScreenState extends State<HomeScreen> {
  //no longer const HomeScreen

  List<String> friends = [
    "Carlos99",
    "AnaGamer",
    "David_23",
    "ElenaPro",
    "GamerX",
    "LuisaK",
    "Pedro_Dev",
    "SophieP",
    "Tommy",
    "ValeriaG",
  ];

  List<String> friendRequests = [
    "Manolo23",
    "SusanaGriso",
    "Nicolas Pueyo",
    "Lacastez",
  ];

  List<String> allUsers = [
    "NewUser1",
    "NewUser2",
    "Mondongo",
    "David Bisbal",
    "Pedro Sanchez",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // Scaffold widget to create the screen
      body: BackgroundWidget(
        // Background image for the screen
        child: SafeArea(
          // SafeArea widget to avoid overlapping with the system status bar
          child: Column(
            // Column widget to stack elements vertically
            children: [
              Padding(
                // Adds padding around the profile button
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  // Aligns the profile button to the top right
                  alignment: Alignment.topRight,
                  child: _buildProfileButton(context, "Jorge1234"),
                ),
              ),

              Expanded(
                // Expanded widget to take up the remaining space
                child: Center(
                  child: Image.asset('images/nogler.png', width: 250),
                ),
              ),

              Padding(
                // Adds padding around the menu buttons
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20,
                ),
                child: Container(
                  // Container to hold the menu buttons
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 100, 99, 99),
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                    border: Border.all(color: Colors.black), // Black border
                  ),
                  child: Wrap(
                    // Wrap widget to create a flow of buttons
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center, // Centers the buttons
                    children: [
                      _buildMenuButton(context, 'OFFLINE', () {}),
                      _buildMenuButton(context, 'JOIN', () {}),
                      _buildMenuButton(context, 'HOST', () {}),
                      _buildMenuButton(context, 'PARTY', () {}),
                      _buildMenuButton(context, 'FRIENDS', () {
                        showFriendsList(
                          context,
                          friends,
                          friendRequests,
                          allUsers,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to create a menu button
  Widget _buildMenuButton(
    BuildContext context,
    String title,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 120,
      height: 50,
      child: ElevatedButton(
        // ElevatedButton widget for the menu button
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 141, 203, 232),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ), // Rounded corners
        ),
        onPressed: onPressed, // Calls the provided function when pressed
        child: Text(
          // Text inside the button
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  /*
  void _showFriendsList(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Pop up border
          ),
          title: const Text(
            "Friends List",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite, // uses the max width of the pop-up
            height: 300, // pop-up height
            child: ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(friends[index][0]), // Change later with images
                  ),
                  title: Text(friends[index]),
                  trailing: Icon(Icons.message, color: Colors.blue),
                  onTap: () {
                    Navigator.pop(
                      context,
                    ); // Closes pop-up when a friend is selected
                    // Add code to see friend's profile
                  },
                );
              },
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween, //aligns both buttons to the sides
              children: [
                //close pop-up button
                TextButton(
                  onPressed: () => Navigator.pop(context), // closes pop-up
                  child: const Text("Close", style: TextStyle(fontSize: 16)),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showFriendRequests(context);
                  },
                  child: const Text(
                    "Friend Requests",
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                //add friends pop-up
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddFriend(context);
                  },
                  child: const Text(
                    "Add Friends",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Users searching pop-up
  void _showAddFriend(BuildContext context) {
    // Change later on when database is implemented

    List<String> filteredUsers = List.from(allUsers);
    //List<String> friends = [];
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          "Add friends",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: "Search user...",
                              hintStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                filteredUsers =
                                    allUsers
                                        .where(
                                          (user) => user.toLowerCase().contains(
                                            value.toLowerCase(),
                                          ),
                                        )
                                        .toList();
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.maxFinite,
                          height: 170,
                          child: ListView.builder(
                            //shrinkWrap: true, //bajo sospecha
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(filteredUsers[index][0]),
                                ),
                                title: Text(filteredUsers[index]),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.person_add,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    if (!friends.contains(
                                      filteredUsers[index],
                                    )) {
                                      setState(() {
                                        friends.add(
                                          filteredUsers[index], //add user to list, later on to the database
                                        );
                                        allUsers.remove(
                                          filteredUsers[index],
                                        ); //remove from allUsers list
                                        filteredUsers.remove(
                                          filteredUsers[index],
                                        );
                                      });
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            //close pop-up button
                            TextButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                ); //TODO, open profile of the user
                                _showFriendsList(context);
                              },
                              child: const Text(
                                "Close",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  void _showFriendRequests(BuildContext context) {
    List<String> filteredUsers = List.from(friendRequests);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Friends Requests",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite, // uses the max width of the pop-up
                //height: 300, // pop-up height
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(child: Text(friends[index][0])),
                      title: Text(filteredUsers[index]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.lightGreen),
                            onPressed: () {
                              setState(() {
                                // add the new friend to the friends list
                                friends.add(filteredUsers[index]);
                                // remove the accepted friend from friendRequests list
                                friendRequests.remove(friendRequests[index]);
                                filteredUsers.remove(filteredUsers[index]);
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                // remove denied friend from friendRequests list
                                friendRequests.remove(friendRequests[index]);
                                filteredUsers.remove(filteredUsers[index]);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showFriendsList(context);
                      },
                      child: const Text("Back", style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
  */

  // Widget to create the profile button
  Widget _buildProfileButton(BuildContext context, String username) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // Style of the button
        backgroundColor: const Color.fromARGB(255, 181, 178, 178),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // Rounded edges
      ),
      onPressed: () {}, // Empty function for now
      child: Column(
        // Column to stack text and username box vertically
        mainAxisSize: MainAxisSize.min, // Minimize the size of the column
        children: [
          const Text(
            // Text inside the button
            "Profile",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(width: 8), // Space between text and username box
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ), // Padding inside the box
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 84, 82, 82),
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
            child: Text(
              // Username text inside the box
              username,
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 17, 17, 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
