import 'package:flutter/material.dart';
import 'package:nogler/widgets/background_widget.dart';

// Home screen of the application
class HomeScreen extends StatelessWidget {
  //no longer const HomeScreen
  const HomeScreen({super.key}); // Constructor for the class

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        _showFriendsList(context);
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

  void _showFriendsList(BuildContext context) {
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

                //add friends pop-up
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddFriendDialog(context);
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
  void _showAddFriendDialog(BuildContext context) {
    // Change later on when database is implemented
    List<String> allUsers = [
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
      "NewUser1",
      "NewUser2",
    ];

    List<String> filteredUsers = List.from(allUsers);
    List<String> friends = [];
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Column(
                children: [
                  const Text(
                    "Add friends",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 7),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search user...",
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
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(filteredUsers[index][0]),
                      ),
                      title: Text(filteredUsers[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_add, color: Colors.green),
                        onPressed: () {
                          if (!friends.contains(filteredUsers[index])) {
                            setState(() {
                              friends.add(
                                filteredUsers[index], //add user to list, later on to the database
                              );
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //close pop-up button
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
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
            );
          },
        );
      },
    );
  }

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
