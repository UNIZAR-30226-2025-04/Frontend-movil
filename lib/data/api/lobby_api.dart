import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nogler/dio/dio_client.dart';

/// Method to create a lobby
Future<void> createLobby(Function(String) onSuccess, String public) async {
  final dioClient = DioClient();
  try {
    final response = await dioClient.dio.post(
      '/auth/CreateLobby',
      data: {'public': public},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.json,
      ),
    );

    if (response.statusCode == 200) {
      // Lobby created succesfully
      debugPrint('✅ Lobby created succesfully');
      onSuccess(response.data["lobby_id"].toString());
    }
  } catch (e) {
    debugPrint('❌ Error creating lobby: $e');
  }
}

/// Method to create a lobby
Future<void> exitLobby(String lobbyCode) async {
  final dioClient = DioClient();
  try {
    final response = await dioClient.dio.post('/auth/exitLobby/$lobbyCode');
    if (response.statusCode == 200) {
      debugPrint('✅ Exited lobby succesfully');
    }
  } catch (e) {
    debugPrint('❌ Error exiting lobby: $e');
  }
}

/// Method to update the lobby visibility
Future<void> updateVisibilityLobby(String lobbyId, String public) async {
  final dioClient = DioClient(); // Create a new Dio client instance
  try {
    // Send a POST request to update the lobby visibility
    final response = await dioClient.dio.post(
      '/auth/setLobbyVisibility/$lobbyId',
      data: {"is_public": public},
      options: Options(
        // Options for the request
        contentType: Headers.formUrlEncodedContentType, // Set the content type
        responseType: ResponseType.json, // Set the response type
      ),
    );

    if (response.statusCode == 200) {
      // If the response is successful (200), print the lobby ID
      debugPrint("✅ Lobby visibility updated: ${response.data}");
    } else {
      // If the response status code is not 200, print an error message
      debugPrint("❌ Error updating lobby visibility: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("❌ Error getting a lobby: $e");
  }
}
