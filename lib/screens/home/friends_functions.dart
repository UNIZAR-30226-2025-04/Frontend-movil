import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nogler/dio/dio_client.dart';

// Show the list of friends of your current profile
void showFriendsList(
  BuildContext context,
  List<String> friends,
  List<String> friendRequests,
  List<String> allUsers,
  String username,
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
                    username,
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
                  showAddFriend(context, username);
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
Future<void> showAddFriend(BuildContext context, String username) async {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> nonFriends = [];
  List<Map<String, dynamic>> filteredFriends = [];
  bool isLoading = true;
  bool hasFetched = false;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          if (!hasFetched) {
            hasFetched = true;
            Future.delayed(Duration.zero, () async {
              final data = await _getNonFriends(username);
              if (context.mounted) {
                setState(() {
                  nonFriends = data;
                  filteredFriends = List.from(nonFriends);
                  isLoading = false;
                });
              }
            });
          }

          void filterSearchResults(String query) {
            setState(() {
              filteredFriends.clear();
              if (query.isEmpty) {
                filteredFriends = List.from(nonFriends);
              } else {
                filteredFriends =
                    nonFriends
                        .where(
                          (user) => user['username'].toLowerCase().contains(
                            query.toLowerCase(),
                          ),
                        )
                        .toList();
              }
            });
          }

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
                          onChanged: filterSearchResults,
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
                              itemCount: filteredFriends.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      filteredFriends[index]['username'][0],
                                    ),
                                  ),
                                  title: Text(
                                    filteredFriends[index]['username'],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.person_add,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      sendFriendRequest(
                                        filteredFriends[index]['username'],
                                      );
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
                              Navigator.pop(context);
                              showFriendsList(context, [], [], [], username);
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
  String username,
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
                        username,
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

/// Function to get a list of users who are neither friends, nor users to whom a friend request has been sent,
/// and excluding the specified username
Future<List<Map<String, dynamic>>> _getNonFriends(String username) async {
  final dioClient = DioClient(); // Create a new Dio client instance
  try {
    // Fetch all users from the API
    final response = await dioClient.dio.get('/allusers');

    // Fetch the current user's friends list
    final friendsResponse = await dioClient.dio.get('/auth/friends');

    // Fetch the list of friend requests that the user has sent
    final sentRequestsResponse = await dioClient.dio.get(
      '/auth/sent_friendship_requests',
    );

    // Fetch the list of friend requests received by the authenticated user
    final receivedRequestsResponse = await dioClient.dio.get(
      '/auth/received_friendship_requests',
    );

    // If the API responses are successful, process the data
    if (response.statusCode == 200 &&
        friendsResponse.statusCode == 200 &&
        sentRequestsResponse.statusCode == 200 &&
        receivedRequestsResponse.statusCode == 200) {
      // Convert the response data to a list of all users
      List<Map<String, dynamic>> allUsers = List<Map<String, dynamic>>.from(
        response.data,
      );

      // Extract a list of friends' usernames from the response
      List<String> friends = List<String>.from(
        friendsResponse.data.map((friend) => friend['username']),
      );

      // Extract a list of usernames to whom friend requests have been sent
      List<String> sentRequests = List<String>.from(
        (sentRequestsResponse.data['sent_friendship_requests'] as List?)?.map(
              (request) => request['username'] as String,
            ) ??
            [], // Handle null and return an empty list if null
      );

      // Extract a list of usernames who have sent friend requests to the user
      List<String> receivedRequests = List<String>.from(
        (receivedRequestsResponse.data['received_friendship_requests'] as List?)
                ?.map((request) => request['username'] as String) ??
            [], // Handle null and return an empty list if null
      );

      // Return a filtered list of users who are neither friends nor those to whom a request has been sent
      return allUsers
          .where(
            (user) =>
                !friends.contains(user['username']) && // Exclude friends
                !sentRequests.contains(
                  user['username'],
                ) && // Exclude users with sent friend requests
                !receivedRequests.contains(
                  user['username'],
                ) && // Exclude users who sent requests to the user
                user['username'] != username, // Exclude the current username
          )
          .toList();
    }
  } catch (e) {
    // Print error message if there is an issue fetching data
    debugPrint("❌ Error fetching non-friends: $e");
  }
  // Return an empty list in case of failure
  return [];
}

/// Function to send a friend request to a specific user
Future<void> sendFriendRequest(String friendUsername) async {
  final dioClient = DioClient(); // Create a new Dio client instance
  try {
    // Send a POST request to the API to send a friend request
    final response = await dioClient.dio.post(
      '/auth/sendFriendshipRequest',
      data: {
        'friendUsername': friendUsername,
      }, // Send the friend's username as form data
      options: Options(
        contentType:
            Headers
                .formUrlEncodedContentType, // Set content type to 'application/x-www-form-urlencoded'
        responseType: ResponseType.json, // Expect JSON response
      ),
    );
    if (response.statusCode == 200) {
      // Print success message if the request was sent successfully
      debugPrint('✅ Friend request sent to $friendUsername');
    }
  } catch (e) {
    // Print error message if sending the request fails
    debugPrint('❌ Failed to send request: $e');
  }
}
