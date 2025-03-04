import 'package:flutter/material.dart';

class InputFieldWidget extends StatelessWidget {
  const InputFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.isPassword,
    required this.size,
  });

  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding widget to add padding around the input field
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        // Row widget to organize the elements horizontally
        crossAxisAlignment:
            CrossAxisAlignment.center, // Align the elements vertically
        children: [
          // Label for the input field
          SizedBox(
            // SizedBox widget to set the width of the label
            width: size,
            child: Text(
              // Text widget to display the label
              label,
              style: const TextStyle(
                // TextStyle widget to style the text
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Input field
          SizedBox(
            // SizedBox widget to set the height and width of the input field
            height: 30,
            width: 240,
            child: TextField(
              // TextField widget to create an input field
              controller: controller, // Set the controller for the input field
              obscureText: isPassword, // Hide the text if it is a password
              decoration: InputDecoration(
                // InputDecoration widget to style the input field
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
