import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nogler/data/api/party_api.dart';
import 'package:nogler/screens/lobby/lobby_screen.dart';
import 'package:page_transition/page_transition.dart'; // For Clipboard

/// Shows a dialog for entering a 4-character code to join a lobby.
///
/// This function takes the [BuildContext] to show the dialog.
Future<void> showCodeDialog(
  BuildContext context,
  String username,
  int iconId,
) async {
  List<TextEditingController> controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: true, // Makes the content scrollable
        backgroundColor: Colors.blueGrey[900],
        title: Text(
          'Join with Code',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center, // Center the title
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // A row of 4 text fields for entering the code
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  width: 50,
                  height: 60,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black87, // Darker background for contrast
                  ),
                  child: Center(
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      keyboardType:
                          TextInputType.text, // Set to alphanumeric keyboard
                      maxLength: 1, // Limit each input field to one character
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30, // Bigger text for better visibility
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        counterText: '', // Hide the character counter
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          // Move to the next field automatically
                          if (index < 3) {
                            FocusScope.of(
                              context,
                            ).requestFocus(focusNodes[index + 1]);
                          } else {
                            FocusScope.of(
                              context,
                            ).unfocus(); // Hide keyboard after last input
                          }
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20), // Add space between text fields and buttons
            // Row for the buttons (Join and Paste Code)
            Row(
              children: [
                Expanded(
                  // Ensures both buttons take the same width
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      // Concatenate the 4 text field values into a single code string
                      String code = controllers
                          .map((controller) => controller.text)
                          .join('');
                      Navigator.of(context).pop(); // Close the dialog
                      final public = await joinLobby(code);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: LobbyScreen(
                              hostName: username,
                              hostAvatar: iconId,
                              lobbyState: !public,
                              lobbyCode: code,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text("Join", style: TextStyle(color: Colors.black)),
                  ),
                ),
                SizedBox(width: 10), // Space between buttons
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      // Get the current clipboard content
                      final clipboardData = await Clipboard.getData(
                        'text/plain',
                      );
                      if (clipboardData != null && clipboardData.text != null) {
                        String clipboardText = clipboardData.text!;
                        // If clipboard text has more than 4 characters, we will take the first 4
                        clipboardText = clipboardText.substring(0, 4);
                        // Assign the clipboard value to each text field
                        for (int i = 0; i < clipboardText.length; i++) {
                          controllers[i].text = clipboardText[i];
                        }
                      }
                    },
                    child: Text(
                      "Paste Code",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
