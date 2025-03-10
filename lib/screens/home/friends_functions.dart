import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nogler/dio/dio_client.dart';
import 'package:nogler/widgets/build_avatar_image.dart';

/// Function to show the list of friends of the current profile
Future<void> showFriendsList(BuildContext context, String username) async {
  List<Map<String, dynamic>> friendsList = [];
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
              final data = await _getFriendsList(); // Function to fetch friends
              if (context.mounted) {
                setState(() {
                  friendsList = List.from(data);
                  isLoading =
                      false; // Set loading to false once data is fetched
                });
              }
            });
          }
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
              child:
                  // Show loading indicator while data is being fetched
                  isLoading
                      ? const Center(
                        child:
                            CircularProgressIndicator(), // Show loading spinner
                      )
                      : friendsList.isEmpty
                      ? Center(
                        child: Text(
                          'No friends available', // Message when no data is available
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount:
                            friendsList.length, // Number of friends to display
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              // Display the avatar image based on the 'icon' ID
                              child: buildAvatarImage(
                                friendsList[index]['icon'],
                              ),
                            ),
                            title: Text(friendsList[index]['username']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.message, color: Colors.blue),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    // Show confirmation dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Confirm deletion'),
                                          content: Text(
                                            'Are you sure you want to remove this friend?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                  context,
                                                ); // Close the dialog
                                              },
                                              child: Text(
                                                'No',
                                              ), // Button to cancel the deletion
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // If user confirms, delete the friend and close the dialog
                                                _deleteFriend(
                                                  friendsList[index]['username'],
                                                ); // Call function to delete the friend
                                                setState(() {
                                                  friendsList.removeAt(
                                                    index,
                                                  ); // Remove the friend from the list
                                                });

                                                Navigator.pop(
                                                  context,
                                                ); // Close the confirmation dialog
                                              },
                                              child: Text(
                                                'Yes',
                                              ), // Button to confirm deletion
                                            ),
                                          ],
                                        );
                                      },
                                    );
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
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween, //aligns both buttons to the sides
                children: [
                  // Close pop-up button
                  TextButton(
                    onPressed: () => Navigator.pop(context), // Closes pop-up
                    child: const Text("Close", style: TextStyle(fontSize: 16)),
                  ),

                  // Friend Requests button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showFriendRequests(context, username);
                    },
                    child: const Text(
                      "Friend Requests",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),

                  // Add Friends button
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

                  // My Requests button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showSentRequest(context, username);
                    },
                    child: const Text(
                      "Sent Requests",
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

/// Function to show the "Add Friends" dialog and allow the user to search and add friends
Future<void> showAddFriend(BuildContext context, String username) async {
  // Controllers and state variables for managing the search and data
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> nonFriends = []; // List of non-friends
  List<Map<String, dynamic>> filteredFriends =
      []; // Filtered list based on search
  bool isLoading = true; // Flag to track loading state
  bool hasFetched = false; // Flag to ensure data is fetched once

  // Show the dialog where users can search and add friends
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Fetch the non-friends list only once when the dialog is first shown
          if (!hasFetched) {
            hasFetched = true;
            Future.delayed(Duration.zero, () async {
              final data = await _getNonFriends(username); // Fetch non-friends
              if (context.mounted) {
                setState(() {
                  nonFriends = data;
                  filteredFriends = List.from(
                    nonFriends,
                  ); // Initialize filtered list
                  isLoading =
                      false; // Set loading to false once data is fetched
                });
              }
            });
          }

          // Function to filter the non-friends list based on the search query
          void filterSearchResults(String query) {
            setState(() {
              filteredFriends.clear();
              if (query.isEmpty) {
                filteredFriends = List.from(
                  nonFriends,
                ); // Show all if query is empty
              } else {
                filteredFriends =
                    nonFriends
                        .where(
                          (user) => user['username'].toLowerCase().contains(
                            query.toLowerCase(), // Filter by username
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
                          controller:
                              searchController, // Controller for the search input
                          decoration: InputDecoration(
                            hintText: "Search user...", // Search hint
                            hintStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            prefixIcon: Icon(Icons.search), // Search icon
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged:
                              filterSearchResults, // Trigger filtering on text change
                        ),
                      ),

                      const SizedBox(height: 10),
                      // Show loading indicator while data is being fetched
                      isLoading
                          ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child:
                                  CircularProgressIndicator(), // Loading spinner while data is being fetched
                            ),
                          )
                          : filteredFriends
                              .isEmpty // Check if the list is empty
                          ? Center(
                            child: Text(
                              "No users available to add", // Message when no requests are present
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : SizedBox(
                            width: double.maxFinite,
                            height: 170,
                            child: ListView.builder(
                              itemCount:
                                  filteredFriends
                                      .length, // Show the filtered friends
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    // Display the avatar image based on the 'icon' ID
                                    child: buildAvatarImage(
                                      filteredFriends[index]['icon'],
                                    ),
                                  ),
                                  title: Text(
                                    filteredFriends[index]['username'], // Display username
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.person_add,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      // Send friend request when button is pressed
                                      _sendFriendRequest(
                                        filteredFriends[index]['username'],
                                      );
                                      // Remove the user from the filteredFriends list after sending the request
                                      setState(() {
                                        filteredFriends.removeAt(
                                          index,
                                        ); // Remove the user at the given index
                                      });
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
                          // Back button to close the dialog
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              showFriendsList(
                                context,
                                username,
                              ); // Show friends list
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

/// Function to show the "Friend Requests" dialog and allow the user to accept or decline requests
Future<void> showFriendRequests(BuildContext context, String username) async {
  // List to store received friend requests
  List<Map<String, dynamic>> receivedRequests = [];
  bool hasFetched = false; // Flag to ensure data is fetched once
  bool isLoading = true; // Flag to track loading state

  // Show the dialog to display the friend requests
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Fetch the received friend requests if not already fetched
          if (!hasFetched) {
            hasFetched = true;
            Future.delayed(Duration.zero, () async {
              final data =
                  await _getReceivedFriendRequests(); // Fetch friend requests from the API
              if (context.mounted) {
                setState(() {
                  receivedRequests = List.from(
                    data,
                  ); // Update the list of received requests
                  isLoading =
                      false; // Set loading to false once data is fetched
                });
              }
            });
          }
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                20,
              ), // Rounded corners for the dialog
            ),
            title: const Text(
              "Friends Requests", // Title of the dialog
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            content: SizedBox(
              width: double.maxFinite, // Uses the max width of the pop-up
              child:
                  // Show loading indicator while data is being fetched
                  isLoading
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                      : receivedRequests
                          .isEmpty // Check if the list is empty
                      ? Center(
                        child: Text(
                          "No friend requests available ", // Message when no requests are present
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount:
                            receivedRequests
                                .length, // Build the list of received friend requests
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              // Display the avatar image based on the 'icon' ID
                              child: buildAvatarImage(
                                receivedRequests[index]['icon'],
                              ),
                            ),
                            title: Text(
                              receivedRequests[index]['username'],
                            ), // Display the username of the requester
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.check,
                                    color:
                                        Colors
                                            .lightGreen, // Green color for accept
                                  ),
                                  onPressed: () {
                                    // Accept the friend request and delete the request
                                    _acceptFriendRequest(
                                      receivedRequests[index]['username'],
                                    );
                                    _deleteFriendRequest(
                                      receivedRequests[index]['username'],
                                    );
                                    setState(() {
                                      receivedRequests.removeAt(
                                        index,
                                      ); // Remove the accepted request from the list
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    // Delete the friend request when declined
                                    _deleteFriendRequest(
                                      receivedRequests[index]['username'],
                                    );
                                    setState(() {
                                      receivedRequests.removeAt(
                                        index,
                                      ); // Remove the declined request from the list
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
                mainAxisAlignment:
                    MainAxisAlignment.end, // Align the back button to the right
                children: [
                  // "Back" button to close the dialog and return to the friends list
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      showFriendsList(
                        context,
                        username,
                      ); // Show the updated friends list after closing the dialog
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

/// Function to show the "Sent Requests" dialog and allow the user to decline his requests
Future<void> showSentRequest(BuildContext context, String username) async {
  // List to store my requests
  List<Map<String, dynamic>> sentRequests = [];
  bool hasFetched = false; // Flag to ensure data is fetched once
  bool isLoading = true; // Flag to track loading state

  // Show the dialog to display the my requests
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Fetch the sent friend requests if not already fetched
          if (!hasFetched) {
            hasFetched = true;
            Future.delayed(Duration.zero, () async {
              final data =
                  await _getSentFriendRequests(); // Fetch the sent friend requests from the API
              if (context.mounted) {
                setState(() {
                  sentRequests = List.from(
                    data,
                  ); // Update the list of the sent friends requests
                  isLoading =
                      false; // Set loading to false once data is fetched
                });
              }
            });
          }
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                20,
              ), // Rounded corners for the dialog
            ),
            title: const Text(
              "Sent Requests", // Title of the dialog
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            content: SizedBox(
              width: double.maxFinite, // Uses the max width of the pop-up
              child:
                  // Show loading indicator while data is being fetched
                  isLoading
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                      : sentRequests
                          .isEmpty // Check if the list is empty
                      ? Center(
                        child: Text(
                          "You haven't sent any friend requests yet", // Message when no requests are present
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount:
                            sentRequests
                                .length, // Build the list of the sent friend requests
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              // Display the avatar image based on the 'icon' ID
                              child: buildAvatarImage(
                                sentRequests[index]['icon'],
                              ),
                            ),
                            title: Text(
                              sentRequests[index]['username'],
                            ), // Display the username of the requester
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    // Delete the sent friend request
                                    _deleteSentFriendRequest(
                                      sentRequests[index]['username'],
                                    );
                                    setState(() {
                                      sentRequests.removeAt(
                                        index,
                                      ); // Remove the deleted request from the list
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
                mainAxisAlignment:
                    MainAxisAlignment.end, // Align the back button to the right
                children: [
                  // "Back" button to close the dialog and return to the friends list
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      showFriendsList(
                        context,
                        username,
                      ); // Show the updated friends list after closing the dialog
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
Future<void> _sendFriendRequest(String friendUsername) async {
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

/// Function to fetch the list of received friend requests
Future<List<Map<String, dynamic>>> _getReceivedFriendRequests() async {
  final dioClient = DioClient();
  try {
    final response = await dioClient.dio.get(
      '/auth/received_friendship_requests', // API endpoint to get the requests
    );

    if (response.statusCode == 200) {
      // Extract and return the list of usernames who sent friend requests to the authenticated user
      return List<Map<String, dynamic>>.from(
        (response.data['received_friendship_requests'] ?? [])
            as List, // If null, return an empty list
      );
    }
  } catch (e) {
    // Handle any error that occurs while fetching the received friend requests
    debugPrint("❌ Error fetching received friend requests: $e");
  }
  // Return an empty list if there is any error or the response is empty
  return [];
}

/// Function to accept a friend request and add a friend
Future<void> _acceptFriendRequest(String friendUsername) async {
  final dioClient = DioClient(); // Create a new Dio client instance
  try {
    // Send a POST request to the API to add a friend
    final response = await dioClient.dio.post(
      '/auth/addFriend', // API endpoint to add a friend
      data: {
        'friendUsername':
            friendUsername, // Send the friend's username to be added
      },
      options: Options(
        contentType:
            Headers
                .formUrlEncodedContentType, // Set content type to 'application/x-www-form-urlencoded'
        responseType: ResponseType.json, // Expect JSON response
      ),
    );
    if (response.statusCode == 200) {
      // Print success message if the friend is added successfully
      debugPrint('✅ Friend added: $friendUsername');
    }
  } catch (e) {
    // Print error message if adding the friend fails
    debugPrint('❌ Failed to add friend: $e');
  }
}

/// Function to delete a received friend request after accepting it
Future<void> _deleteFriendRequest(String friendUsername) async {
  final dioClient = DioClient(); // Create a new Dio client instance
  try {
    // Send a DELETE request to remove the received friendship request
    final response = await dioClient.dio.delete(
      '/auth/received_friendship_request/$friendUsername',
    );

    if (response.statusCode == 200) {
      // Print success message if the request was deleted successfully
      debugPrint(
        '✅ Friendship request from $friendUsername deleted successfully',
      );
    }
  } catch (e) {
    // Handle errors during the deletion process
    debugPrint('❌ Error deleting friend request: $e');
  }
}

/// Function to fetch the list of friends of the current user
Future<List<Map<String, dynamic>>> _getFriendsList() async {
  final dioClient = DioClient(); // Create a new Dio client instance
  try {
    final response = await dioClient.dio.get(
      '/auth/friends', // API endpoint to get the list of friends
    );

    if (response.statusCode == 200) {
      // Return the list of friends
      return List<Map<String, dynamic>>.from(response.data);
    }
  } catch (e) {
    // Handle any error that occurs during the API call
    debugPrint('❌ Error fetching friends list: $e');
  }
  // Return an empty list if there's an error or no friends
  return [];
}

/// Function to delete a friend
Future<void> _deleteFriend(String friendUsername) async {
  final dioClient = DioClient(); // Create a new Dio client instance
  try {
    final response = await dioClient.dio.delete(
      '/auth/deleteFriend/$friendUsername', // API endpoint to delete a friend
    );

    if (response.statusCode == 200) {
      // Print success message if the friend was deleted successfully
      debugPrint('✅ Friend $friendUsername deleted successfully');
    }
  } catch (e) {
    // Handle errors during the deletion process
    debugPrint('❌ Error deleting friend: $e');
  }
}

/// Function to fetch the list of my sent friend requests
Future<List<Map<String, dynamic>>> _getSentFriendRequests() async {
  final dioClient = DioClient();
  try {
    final response = await dioClient.dio.get(
      '/auth/sent_friendship_requests', // Correct endpoint to get sent requests
    );

    if (response.statusCode == 200) {
      // Extract and return the list of usernames who I sent friend requests
      return List<Map<String, dynamic>>.from(
        (response.data['sent_friendship_requests'] ?? [])
            as List, // Correct access to the field
      );
    }
  } catch (e) {
    // Handle any error that occurs while fetching my friend requests
    debugPrint("❌ Error fetching my friend requests: $e");
  }
  // Return an empty list if there is any error or the response is empty
  return [];
}

/// Function to delete a sent friend request
Future<void> _deleteSentFriendRequest(String friendUsername) async {
  final dioClient = DioClient(); // Create a new Dio client instance
  try {
    // Send a DELETE request to remove the sent friendship request
    final response = await dioClient.dio.delete(
      '/auth/sent_friendship_request/$friendUsername',
    );

    if (response.statusCode == 200) {
      // Print success message if the request was deleted successfully
      debugPrint(
        '✅ Friendship request to $friendUsername deleted successfully',
      );
    }
  } catch (e) {
    // Handle errors during the deletion process
    debugPrint('❌ Error deleting friend request: $e');
  }
}
