import 'package:flutter/material.dart';
import 'package:nogler/websocket/websocket_client.dart';

class ChooseBlindFaseWidget extends StatefulWidget {
  const ChooseBlindFaseWidget({
    super.key,
    required this.lobbyCode,
    required this.minBlind,
    required this.onBlind,
  });

  final String lobbyCode;
  final int minBlind;
  final Function(int)? onBlind;

  @override
  ChooseBlindFaseWidgetState createState() => ChooseBlindFaseWidgetState();
}

class ChooseBlindFaseWidgetState extends State<ChooseBlindFaseWidget> {
  final wsClient = WebSocketClient();
  // Controller to modify the TextEditing widget
  final TextEditingController _controller = TextEditingController();

  bool hasFetched = true;

  int minScore = 0;

  @override
  void initState() {
    super.initState();
    minScore = widget.minBlind;
  }

  @override
  Widget build(BuildContext context) {
    if (hasFetched) {
      _controller.text = minScore.toString();
      hasFetched = false;
    }
    return Container(
      width: 400,
      height: 196,
      decoration: BoxDecoration(
        color: Color.fromRGBO(44, 54, 86, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.fromLTRB(0, 64, 0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title of the widget
          Text(
            "Choose a blind",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          SizedBox(height: 6),

          // Show min score to introduce
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Min score:",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(width: 6),
              Container(
                width: 70,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF0ea5e9),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$minScore",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),

          Row(
            children: [
              SizedBox(width: 6),
              // -100 chips button
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    int aux = int.parse(_controller.text);
                    if (minScore > (aux - 100)) {
                      aux = minScore;
                    } else {
                      aux = aux - 100;
                    }
                    setState(() {
                      _controller.text = aux.toString();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd41976),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        topLeft: Radius.circular(12),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    "-100",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              // Textfield to enter the chips to superpass
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromRGBO(62, 76, 123, 1),
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  ),
                ),
              ),

              // +100 chips button
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    int aux = int.parse(_controller.text);
                    if (aux < minScore) {
                      setState(() {
                        _controller.text = (minScore).toString();
                      });
                    } else {
                      setState(() {
                        _controller.text = (aux + 100).toString();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0ea5e9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    "+100",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              SizedBox(width: 6),
            ],
          ),
          SizedBox(height: 6),

          // Button to send your blind request
          ElevatedButton(
            onPressed: () {
              setState(() {
                minScore = int.tryParse(_controller.text) ?? minScore;
              });
              widget.onBlind?.call(minScore);
              wsClient.sendMessage('propose_blind', {
                minScore,
                widget.lobbyCode,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0ea5e9),
            ),
            child: Text("Place blind", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
