import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nogler/screens/loading/loading_screen.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:page_transition/page_transition.dart';

/// Displays a dialog showing the types of hands in the game.
Future<void> showHandTypes(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 400,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3454),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hand types',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'X',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lista scrollable
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    _buildDataRow('lvl.1', 'Flush five', '160', 'X', '16'),
                    _buildDataRow('lvl.1', 'Flush house', '140', 'X', '14'),
                    _buildDataRow('lvl.1', 'Five of a kind', '120', 'X', '12'),
                    _buildDataRow('lvl.1', 'Royal flush', '100', 'X', '8'),
                    _buildDataRow('lvl.1', 'Straight flush', '100', 'X', '8'),
                    _buildDataRow('lvl.1', 'Four of a kind', '60', 'X', '1'),
                    _buildDataRow('lvl.1', 'Full house', '40', 'X', '4'),
                    _buildDataRow('lvl.1', 'Flush', '38', 'X', '4'),
                    _buildDataRow('lvl.1', 'Straight', '30', 'X', '4'),
                    _buildDataRow('lvl.1', 'Three of a kind', '30', 'X', '3'),
                    _buildDataRow('lvl.1', 'Two pair', '20', 'X', '2'),
                    _buildDataRow('lvl.1', 'One pair', '10', 'X', '2'),
                    _buildDataRow('lvl.1', 'High card', '3', 'X', '1'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Builds a data row for the hand types dialog.
Widget _buildDataRow(
  String level,
  String type,
  String points,
  String x,
  String multiplier,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    child: Row(
      children: [
        // Level
        Container(
          width: 60,
          height: 30,
          decoration: BoxDecoration(
            color: Color(0xFF495a8f),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              level,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Type
        Expanded(
          child: Center(
            child: Text(
              type,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Points, X, and Multiplier
        Container(
          width: 150,
          decoration: BoxDecoration(
            color: Color(0xFF495a8f),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Spacing between children
            children: [
              // Points at the left
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0ea5e9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    points,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // X in the middle
              const Text(
                'X',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Multiplier at the right
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFd41976),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    multiplier,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Displays a dialog to propose a blind value.
Future<void> showSimpleBlindDialog(BuildContext context, String lobbyId) async {
  final wsClient = WebSocketClient();
  int proposedBlind = 1;
  final TextEditingController controller = TextEditingController();

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          scrollable: true,
          backgroundColor: const Color(0xFF2C3454), // Custom background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Center(
                child: Text(
                  'Enter Blind Value',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Numeric input field
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Blind value',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  proposedBlind = int.tryParse(value) ?? 1;
                },
              ),
              const SizedBox(height: 30),

              // Confirm button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    if (controller.text.isNotEmpty && proposedBlind > 0) {
                      wsClient.sendMessage('propose_blind', {
                        proposedBlind,
                        lobbyId,
                      });
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: const LoadingScreen(
                            loadingMessage: 'Starting round ...',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid blind value'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
