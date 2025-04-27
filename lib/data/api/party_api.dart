import 'package:flutter/material.dart';
import 'package:nogler/dio/dio_client.dart';

/// Function to get the list of received game lobby invitations
Future<List<Map<String, dynamic>>> getReceivedGameLobbyInvitations() async {
  final dioClient = DioClient(); // Create a new Dio client instance

  try {
    // Send GET request to fetch received game lobby invitations
    final response = await dioClient.dio.get(
      '/auth/received_lobby_invitations', // API endpoint
    );

    // Check if the response status is 200 (OK)
    if (response.statusCode == 200) {
      // Return the list of received invitations or an empty list if none found
      return List<Map<String, dynamic>>.from(
        (response.data['received_game_lobby_invitations'] ?? []) as List,
      );
    }
  } catch (e) {
    // Handle any errors while fetching the data
    debugPrint("❌ Error fetching received game lobby invitations: $e");
  }

  // Return an empty list in case of error or no data
  return [];
}

/// Function to add the user to the user-lobby relation
Future<bool> joinLobby(String lobbyId) async {
  final dioClient = DioClient(); // Create a new Dio client instance
  try {
    // Send a POST request to the API to add the user to the lobby
    final response = await dioClient.dio.post(
      '/auth/joinLobby/$lobbyId', // API endpoint to add the user to the specified lobby
    );
    if (response.statusCode == 200) {
      // Print success message if the user is successfully added to the lobby
      debugPrint('✅ User added to lobby: $lobbyId');
      return response.data['lobby_info']['public'].toString() == '1'?  true: false;
    }
  } catch (e) {
    // Print error message if adding the user to the lobby fails
    debugPrint('❌ Failed to add user to lobby: $e');
  }
  return false;
}

/// Function to delete a received game lobby invitation after accepting it
Future<void> deleteLobbyInvitation(
  String lobbyId,
  String senderUsername,
) async {
  final dioClient = DioClient(); // Create a new Dio client instance
  try {
    // Send a DELETE request to remove the received game lobby invitation
    final response = await dioClient.dio.delete(
      '/auth/received_lobby_invitation/$lobbyId/$senderUsername', // API endpoint to delete the received invitation
    );

    if (response.statusCode == 200) {
      // Print success message if the invitation was deleted successfully
      debugPrint(
        '✅ Game lobby invitation from $senderUsername for lobby $lobbyId deleted successfully',
      );
    }
  } catch (e) {
    // Handle errors during the deletion process
    debugPrint('❌ Error deleting lobby invitation: $e');
  }
}

/// Function to fetch the information of a lobby by its ID
Future<Map<String, dynamic>?> getLobbyInfo(String lobbyId) async {
  final dioClient = DioClient(); // Create a new Dio client instance
  try {
    final response = await dioClient.dio.get(
      '/auth/lobbyInfo/$lobbyId', // API endpoint to get lobby info
    );

    if (response.statusCode == 200) {
      // Extract and return the lobby information as a Map
      return response.data as Map<String, dynamic>;
    }
  } catch (e) {
    // Handle any error that occurs while fetching the lobby info
    debugPrint("❌ Error fetching lobby info: $e");
  }
  // Return null if there is any error or the response is empty
  return null;
}
