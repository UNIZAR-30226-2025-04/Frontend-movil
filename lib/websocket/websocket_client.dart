import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Singleton for managing WebSocket connections.
class WebSocketClient {
  static final WebSocketClient _instance = WebSocketClient._internal();
  late io.Socket socket;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  // Map to store dynamic event handlers
  final Map<String, Function(dynamic)> _eventHandlers = {};

  // Authentication credentials
  String? code;
  String? token;

  /// Factory constructor to always return the same instance
  factory WebSocketClient() {
    return _instance;
  }

  // Private constructor for Singleton
  WebSocketClient._internal();

  /// Initialize and connect to the WebSocket server.
  Future<void> initialize() async {
    try {
      // Retrieve authentication credentials.
      token = await _storage.read(key: 'session_token');
      code = await _storage.read(key: 'code');

      // If credentials are missing, do not attempt connection.
      if (token == null ||
          token?.isEmpty == true ||
          code == null ||
          code?.isEmpty == true) {
        debugPrint("⚠ Cannot connect: Missing token or username.");
        return;
      }

      debugPrint("🔑 Using token: $token");

      // Initialize WebSocket connection without explicitly calling `connect()`.
      socket = io.io(
        'https://nogler.ddns.net:443',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setAuth({'authorization': "Bearer $token"})
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

      socket.on("connection_success", (reason) {
        debugPrint("🟢 Connection successful: $reason");
        sendMessage("join_lobby", code);
        sendMessage("get_lobby_info", code);
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

      // Event: Authentication failure (log out user).
      socket.on("error", (data) {
        debugPrint('❌ WebSocket Server Error: $data');
        if (data != null && data.toString().contains("Authentication failed")) {
          debugPrint('🚫 Authentication error detected. Logging out...');
          _handleAuthenticationError();
        }
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

  /// Add a dynamic event listener.
  void addEventListener(String event, Function(dynamic) callback) {
    removeEventListener(event);
    _eventHandlers[event] = callback;
    socket.on(event, callback);
    debugPrint("✅ Added listener for event: $event");
  }

  /// Remove a specific event listener.
  void removeEventListener(String event) {
    if (_eventHandlers.containsKey(event)) {
      socket.off(event, _eventHandlers[event]);
      _eventHandlers.remove(event);
      debugPrint("❌ Removed listener for event: $event");
    }
  }

  /// Send a message to the WebSocket server.
  Future<void> sendMessage(String event, dynamic data) async {
    if (socket.connected) {
      socket.emit(event, data);
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
