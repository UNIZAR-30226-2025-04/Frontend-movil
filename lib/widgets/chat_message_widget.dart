import 'package:flutter/material.dart';
import 'package:nogler/widgets/build_avatar_image.dart';

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({
    super.key,
    required this.username,
    required this.avatarImage,
    required this.message,
    required this.time,
  });

  final String username;
  final int avatarImage;
  final String message;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show the user's avatar image
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 5.0, 5.0, 0),
          child: Align(
            child: Container(
              alignment: Alignment.topRight,
              constraints: BoxConstraints(
                minWidth: 30,
                minHeight: 30,
                maxWidth: 40,
                maxHeight: 40,
              ),
              child: buildAvatarImage(avatarImage),
            ),
          ),
        ),

        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D5566),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name of the user
                Text(
                  username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                // Text of the message
                if (message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      message,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                // Time the message has been sent
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
