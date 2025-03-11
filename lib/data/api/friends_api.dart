import 'package:flutter/material.dart';
import 'package:nogler/dio/dio_client.dart';
import 'package:dio/dio.dart';

/// Function to get a list of users who are neither friends, nor users to whom a friend request has been sent,
/// and excluding the specified username
Future<List<Map<String, dynamic>>> getNonFriends(String username) async {
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

/// Function to fetch the list of received friend requests
Future<List<Map<String, dynamic>>> getReceivedFriendRequests() async {
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
Future<void> acceptFriendRequest(String friendUsername) async {
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
Future<void> deleteFriendRequest(String friendUsername) async {
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
Future<List<Map<String, dynamic>>> getFriendsList() async {
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
Future<void> deleteFriend(String friendUsername) async {
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
Future<List<Map<String, dynamic>>> getSentFriendRequests() async {
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
Future<void> deleteSentFriendRequest(String friendUsername) async {
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
