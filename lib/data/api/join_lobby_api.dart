import 'package:flutter/material.dart';
import 'package:nogler/dio/dio_client.dart';

/// Function to fetch all lobbies
Future<List<Map<String, dynamic>>> getAllLobbies() async {
  final dioClient = DioClient(); // Create a new Dio client instance
  try {
    // Send a GET request to fetch all lobbies
    final response = await dioClient.dio.get('/auth/getAllLobbies');

    // Convert the response data to a list of lobbies or return an empty list if no data is available
    List<Map<String, dynamic>> lobbies = List<Map<String, dynamic>>.from(
      response.data ?? [],
    );

    // Return the list of lobbies (empty if none)
    return lobbies;
  } catch (e) {
    // Print error message if there is an issue fetching data
    debugPrint("❌ Error fetching lobbies: $e");
  }

  // Return an empty list in case of failure
  return [];
}

/// Function to fetch all lobbies
Future<String> getLobby() async {
  final dioClient = DioClient(); // Create a new Dio client instance
  try {
    // Send a POST request to fetch a lobby
    final response = await dioClient.dio.get('/auth/matchMaking');
    debugPrint("🔍 Response data: ${response.data}");

    if (response.statusCode == 200) {
      final lobbyId = response.data['lobby_id'];
      // Return the code of the lobby or an empty string if no data is available
      return lobbyId ?? "";
    } else {
      // Print error message if the response status code is not 200
      debugPrint("❌ Error fetching lobby: ${response.statusCode}");
    }
  } catch (e) {
    // Print error message if there is an issue fetching data
    debugPrint("❌ Error getting a lobby: $e");
  }

  // Return an empty String in case of failure
  return "";
}
