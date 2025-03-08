import 'package:flutter/material.dart';
import 'package:nogler/dio/dio_client.dart';

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
                  showAddFriend(context);
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
Future<void> showAddFriend(BuildContext context) async {
  //List<String> friends = [];
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> nonFriends = [];
  bool isLoading = true;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future.delayed(Duration.zero, () async {
            final data = await _getNonFriends();
            if (context.mounted) {
              setState(() {
                nonFriends = data;
                isLoading = false;
              });
            }
          });
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
                          onChanged: (value) async {},
                        ),
                      ),

                      const SizedBox(height: 10),
                      isLoading
                          ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                          : SizedBox(
                            width: double.maxFinite,
                            height: 170,
                            child: ListView.builder(
                              itemCount: nonFriends.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      nonFriends[index]['username'][0],
                                    ),
                                  ),
                                  title: Text(nonFriends[index]['username']),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.person_add,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {},
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
                              Navigator.pop(context);
                              showFriendsList(context, [], [], []);
                            },
                            child: const Text(
                              "Back",
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

Future<List<Map<String, dynamic>>> _getNonFriends() async {
  final dioClient = DioClient();
  try {
    final response = await dioClient.dio.get('/allusers');
    final friendsResponse = await dioClient.dio.get('/auth/friends');

    if (response.statusCode == 200 && friendsResponse.statusCode == 200) {
      List<Map<String, dynamic>> allUsers = List<Map<String, dynamic>>.from(
        response.data,
      );
      List<String> friends = List<String>.from(
        friendsResponse.data.map((friend) => friend['username']),
      );
      return allUsers
          .where((user) => !friends.contains(user['username']))
          .toList();
    }
  } catch (e) {
    debugPrint("❌ Error fetching non-friends: $e");
  }
  return [];
}
