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
