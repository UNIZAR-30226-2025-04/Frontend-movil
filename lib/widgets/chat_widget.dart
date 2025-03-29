import 'package:flutter/material.dart';
import 'package:nogler/widgets/chat_message_widget.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  // Controller for the chat
  final TextEditingController _controller = TextEditingController();
  // Controller to scroll automaticly to the new message sent
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> chatMessages = [
    // formato: {username, message, time}
    {"username": "hola", "message": "Hola", "time": "13:14"}, //example
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF27384C), // azul oscuro del fondo
      child: Column(
        children: [
          // List of messages in the chat
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(10),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final msg = chatMessages[index];
                return ChatMessageWidget(
                  username: msg['username'] ?? "",
                  avatarImage: 1,
                  message: msg['message'] ?? "",
                  time: msg['time'] ?? "",
                );
              },
            ),
          ),
          Divider(color: Colors.white54),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
            child: Row(
              children: [
                // Textfield where you write the message
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Write a message...',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF1C2B3A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // Button to send the message to the chat
                ElevatedButton(
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        // Add message to the list
                        chatMessages.add({
                          "username": "Tú",
                          "message": text,
                          "time": TimeOfDay.now().format(context),
                        });
                        // Clear the textfield
                        _controller.clear();

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                        });
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text("Send"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
//TODO, chatgptmade de momento
Widget buildChatDrawer(List<Map<String, String>> chatMessages) {
  return Drawer(
    backgroundColor: const Color(0xFF27384C), // azul oscuro del fondo
    child: Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: chatMessages.length,
            itemBuilder: (context, index) {
              final msg = chatMessages[index];
              return ChatMessageWidget(
                username: msg['username'] ?? "",
                message: msg['message'] ?? "",
                time: msg['time'] ?? "",
              );
            },
          ),
        ),
        Divider(color: Colors.white54),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Write a message...',
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF1C2B3A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text("Send"),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
*/
