import 'package:flutter/material.dart';
import 'package:nogler/widgets/chat_message_widget.dart';

//TODO, chatgptmade de momento
Widget buildChatDrawer() {
  return Drawer(
    backgroundColor: const Color(0xFF27384C), // azul oscuro del fondo
    child: Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(10),
            children: [
              buildChatMessage("hola", "Hola", "13:14"),
              buildChatMessage("hola", "asd", "13:14"),
              buildChatMessage("hola", "", "13:14"),
              buildChatMessage("hola", "asdas", "13:14"),
            ],
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
                  // lógica para enviar mensaje
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
