import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Singleton for managing WebSocket connections.
class WebSocketClient {
  static final WebSocketClient _instance = WebSocketClient._internal();
  late io.Socket socket;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Factory constructor to always return the same instance.
  factory WebSocketClient() {
    return _instance;
  }

  /// Private constructor for Singleton.
  WebSocketClient._internal();

  /// Initialize and connect to the WebSocket server.
  Future<void> initialize() async {
    try {
      // Retrieve authentication credentials.
      String? token = await _storage.read(key: 'session_token');
      String? username = await _storage.read(key: 'username');

      // If credentials are missing, do not attempt connection.
      if (token == null ||
          token.isEmpty ||
          username == null ||
          username.isEmpty) {
        debugPrint("⚠ Cannot connect: Missing token or username.");
        return;
      }

      debugPrint("🔑 Using token: $token");
      debugPrint("👤 Username: $username");

      // Initialize WebSocket connection without explicitly calling `connect()`.
      socket = io.io(
        'https://nogler.ddns.net:443',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setAuth({'username': username, 'authorization': "Bearer $token"})
            .setTimeout(10000)
            .enableForceNew() // Ensures a fresh connection each time
            .build(),
      );

      // Log any event received for debugging.
      socket.onAny((event, data) {
        debugPrint("📡 Received Event: '$event' | Data: $data");
      });

      // Event: Connected to the WebSocket server.
      socket.on("connect", (_) {
        debugPrint('🟢 Connected to WebSocket server.');
        debugPrint('🔄 Connection Details: ${socket.id}');
      });

      // Event: Disconnected from server.
      socket.on("disconnect", (reason) {
        debugPrint('🔴 Disconnected from WebSocket. Reason: $reason');

        if (reason == "ping timeout") {
          debugPrint(
            "⚠ Possible cause: No PING response was received from the server.",
          );
        } else if (reason == "transport close") {
          debugPrint(
            "⚠ Possible cause: Network connection lost or server closed the connection.",
          );
        } else if (reason == "server disconnect") {
          debugPrint(
            "⚠ Possible cause: The server forcibly disconnected the client.",
          );
        } else if (reason == "client disconnect") {
          debugPrint(
            "⚠ Possible cause: The client manually closed the connection.",
          );
        }
      });

      // Event: Handle WebSocket errors.
      socket.on("error", (data) {
        debugPrint('⚠ WebSocket error: $data');
      });

      // Event: Authentication failure (log out user).
      socket.on("error", (data) {
        debugPrint('❌ WebSocket Server Error: $data');
        if (data != null && data.toString().contains("Authentication failed")) {
          debugPrint('🚫 Authentication error detected. Logging out...');
          _handleAuthenticationError();
        }
      });

      // Event: Lobby-related actions.
      socket.on("join_lobby", (data) {
        debugPrint("🏠 Lobby Joined: $data");
      });

      socket.on("exit_lobby", (data) {
        debugPrint("🚪 Lobby Exit Response: $data");
      });

      socket.on("kick_from_lobby", (data) {
        debugPrint("🥾 Kicked from Lobby: $data");
      });

      socket.on("broadcast_to_lobby", (data) {
        debugPrint("📢 Broadcast Message: $data");
      });

      socket.on("play_hand", (data) {
        debugPrint("🎲 Play Hand Response: $data");
      });

      // Start listening to events.
      socket.connect(); // 🔥 Event-driven connection.
    } catch (e) {
      debugPrint('🚨 Initialization failed: $e');
    }
  }

  /// Handle authentication failures by clearing credentials and disconnecting.
  Future<void> _handleAuthenticationError() async {
    debugPrint("🚪 Clearing session and logging out user...");
    await _storage.delete(key: 'session_token');
    await _storage.delete(key: 'username');
    disconnect();
  }

  /// Send a message to the WebSocket server.
  void sendMessage(String event, dynamic data) {
    if (socket.connected) {
      debugPrint("📤 Sent message to event '$event': $data");
    } else {
      debugPrint("⚠ Cannot send message, WebSocket is disconnected.");
    }
  }


  /// Disconnect from the WebSocket server.
  void disconnect() {
    socket.disconnect();
    socket.clearListeners();
    debugPrint('🔌 WebSocket disconnected');
  }
}
