import 'package:flutter/material.dart';

//TODO, chatgptmade de momento
Widget buildChatMessage(String username, String message, String time) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 6),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF2D5566),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          username,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        if (message.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              message,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            time,
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ),
      ],
    ),
  );
}
