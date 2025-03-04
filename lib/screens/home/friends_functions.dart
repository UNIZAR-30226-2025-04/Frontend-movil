import 'package:flutter/material.dart';

// Show the list of friends of your current profile
void showFriendsList(
  BuildContext context,
  List<String> friends,
  List<String> friendRequests,
  List<String> allUsers,
) {
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
                  showFriendRequests(
                    context,
                    friends,
                    friendRequests,
                    allUsers,
                  );
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
                  showAddFriend(context, friends, friendRequests, allUsers);
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
void showAddFriend(
  BuildContext context,
  List<String> friends,
  List<String> friendRequests,
  List<String> allUsers,
) {
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
                                  if (!friends.contains(filteredUsers[index])) {
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
                              showFriendsList(
                                context,
                                friends,
                                friendRequests,
                                allUsers,
                              );
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

void showFriendRequests(
  BuildContext context,
  List<String> friends,
  List<String> friendRequests,
  List<String> allUsers,
) {
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
                      showFriendsList(
                        context,
                        friends,
                        friendRequests,
                        allUsers,
                      );
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
