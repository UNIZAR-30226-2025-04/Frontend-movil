import 'package:flutter/material.dart';
import 'package:nogler/dio/dio_client.dart';
import 'package:dio/dio.dart';

/// Function to get a list of users who are friends and are not yet invited to an specific lobby
Future<List<Map<String, dynamic>>> getAllNonInvitedFriends(
  String lobbyCode,
) async {
  final dioClient = DioClient();
  try {
    //Current username
    final meResponse = await dioClient.dio.get('/auth/me');

    //List of all friends
    final friendsResponse = await dioClient.dio.get('/auth/friends');

    //List of all invited friends
    final invitationsResponse = await dioClient.dio.get(
      '/auth/sent_lobby_invitations',
    );

    //List of all non invited friends
    if (meResponse.statusCode == 200 &&
        friendsResponse.statusCode == 200 &&
        invitationsResponse.statusCode == 200) {
      // Current user username
      String username = meResponse.data['username'].toString();

      // List of all friends
      List<Map<String, dynamic>> friends = List<Map<String, dynamic>>.from(
        friendsResponse.data,
      );

      // Extract a list of usernames who have been sent an invitation by the user
      List<Map<String, dynamic>> sentInvitations =
          List<Map<String, dynamic>>.from(
            invitationsResponse.data['sent_game_lobby_invitations'] ?? [],
          );

      // Return a filtered list of users who aren't yet invited to the lobby
      return friends
          .where(
            (user) =>
                !sentInvitations.contains(user['username']) &&
                user['lobby_id'] != lobbyCode &&
                user['username'] != username,
          )
          .toList();
    }
  } catch (e) {
    debugPrint("❌ Error fetching friends to invite: $e");
  }

  return [];
}

/// Function to get a list of users who are friends and are invited to an specific lobby
Future<List<Map<String, dynamic>>> getAllInvitedFriends(
  String lobbyCode,
) async {
  final dioClient = DioClient();
  try {
    //Current username
    final meResponse = await dioClient.dio.get('/auth/me');

    //List of all invited friends
    final invitationsResponse = await dioClient.dio.get(
      '/auth/sent_lobby_invitations',
    );

    if (meResponse.statusCode == 200 && invitationsResponse.statusCode == 200) {
      // Current user username
      String username = meResponse.data['username'].toString();

      List<Map<String, dynamic>> sentInvitations =
          List<Map<String, dynamic>>.from(
            invitationsResponse.data['sent_game_lobby_invitations'] ?? [],
          );

      return sentInvitations
          .where(
            (user) =>
                user['lobby_id'] == lobbyCode && user['username'] != username,
          )
          .toList();
    }
  } catch (e) {
    debugPrint("❌ Error fetching invited friends: $e");
  }

  return [];
}

/// Function to send an invitation to a friend
Future<void> sendInvitation(String lobbyCode, String friendUsername) async {
  final dioClient = DioClient();
  try {
    final response = await dioClient.dio.post(
      '/auth/sendLobbyInvitation',
      data: {
        'lobby_id': lobbyCode,
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
      debugPrint('✅ Invitation sent to $friendUsername');
    }
  } catch (e) {
    debugPrint('❌ Failed to send invitation: $e');
  }
}

/// Function to delete an invitation sent to a friend
Future<void> deleteInvitation(String lobbyCode, String friendUsername) async {
  final dioClient = DioClient();
  try {
    // Send delete request to remove invitation
    final response = await dioClient.dio.delete(
      '/auth/sent_lobby_invitation/$lobbyCode/$friendUsername',
    );

    if (response.statusCode == 200) {
      debugPrint(
        '✅ Invitation request to $friendUsername in lobby $lobbyCode deleted successfully',
      );
    }
  } catch (e) {
    debugPrint('❌ Error deleting invitation: $e');
  }
}
