import 'package:flutter/material.dart';
import 'package:nogler/dio/dio_client.dart';
import 'package:dio/dio.dart';

///Method to create a lobby
Future<void> createLobby(
  Function(String?) onError,
  Function(String) onSuccess,
) async {
  final dioClient = DioClient();
  try {
    final response = await dioClient.dio.post(
      '/auth/CreateLobby',
      /*
      options: Options(
        contentType:
            Headers
                .formUrlEncodedContentType, // Set content type to 'application/x-www-form-urlencoded'
        responseType: ResponseType.json, // Expect JSON response
      ),
      */
    );

    if (response.statusCode == 200) {
      // Lobby created succesfully
      debugPrint('✅ Lobby created succesfully');
      onSuccess(response.data["lobby_id"].toString());
    }
  } catch (e) {
    debugPrint('❌ Error creating lobby: $e');
    onError('Error creating lobby');
  }
}
