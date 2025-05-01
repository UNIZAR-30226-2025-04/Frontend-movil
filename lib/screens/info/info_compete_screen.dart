import 'package:flutter/material.dart';
import 'package:nogler/widgets/background_widget.dart';

/// Screen that shows the rules of the competition system
class InfoCompeteScreen extends StatelessWidget {
  const InfoCompeteScreen({super.key});

  /// The build method is used to describe how to display the widget on the screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold widget to create the screen
      body: BackgroundWidget(
        // Background image for the screen
        child: SafeArea(
          // SafeArea widget to avoid the status bar
          child: Padding(
            // Padding widget to add padding around the content
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              // Column widget to organize the screen vertically
              children: [
                Padding(
                  // Padding widget to add space around the row
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    // Row widget to organize the elements horizontally
                    children: [
                      IconButton(
                        // IconButton widget to create a button with an icon
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(), // Spacer widget to add space between elements
                      const Text(
                        // Text widget to display text
                        'Compete',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(), // Spacer widget to add space between elements
                      const SizedBox(
                        width: 48,
                      ), // SizedBox widget to add space between elements
                    ],
                  ),
                ),
                Expanded(
                  // Expanded widget to fill the available space
                  child: Center(
                    // Center widget to center the container
                    child: Container(
                      // Container widget to create a container
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.height * 0.6,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        // BoxDecoration widget to add decoration to the container
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Border radius of the container
                      ),
                      // Too much text, so make it scrollable
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Now that you have ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: RainbowText(text: "(for sure)"),
                                  ),
                                  TextSpan(
                                    text:
                                        " read all the other texts, lets dive into the game itself.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "In order to start playing, you have 2 different options, play against an ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "IA",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.red,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        " alone to improve into the game and know the different effects of the cards, or you can play ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Online",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ", which will require other people to play against.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "To play against the IA, you only have to enter the home menu and press the ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "VS IA button",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.red,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ", which will lead into the game directly.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "In case you want to play online you can create a lobby to invite up to 8 of your friends and enter the game when the creator decides to.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "If you have ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: RainbowText(
                                      text: "no friends",
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        " (thats fine, we already thought about that) you can enter the join lobby section from the home menu which will lead into a list of all current public lobbies which have not yet started.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        "\nIn the lobby you can socialize with the people in there via chat, where there are no limits ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "(DONT BE TOO RUDE 😡)",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "Now that you have a lobby to play lets explain the phases:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        "\nThere are three diferenced phases, ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "the game phase",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.purple[800],
                                    ),
                                  ),
                                  TextSpan(
                                    text: ",",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " the shopping phase",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.yellow[800],
                                    ),
                                  ),
                                  TextSpan(
                                    text: " and ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "the consumable phase",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Game Fase pharagraph
                            SizedBox(height: 5),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "In the ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "the game phase",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.purple[800],
                                    ),
                                  ),

                                  TextSpan(
                                    text:
                                        " you have to play poker hands in order to get chips and reach a certain amount of chips. That certain amount of chips will be selected by all players before playing your cards. The game will choose the maximum amount introduced by a player.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        "\nNow everyone has to reach that certain amount of chips. If the player who chose the amount of chips doesn't reach it, that player loses a life while every other player don't. If that player reaches the amount of chips then every player has the obligation to superpass it if they don't want to lose a life.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),

                            // Shop Fase pharagraph
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "After we conclude the game fase, everyone (who's not eliminated) will enter the ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " the shopping phase",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.yellow[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),

                            // Consumable Fase pharagraph
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "After you finish shopping in last place we have ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "the consumable phase",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ", where you can throw all the consumables you have bought during the shop fase. Use them on your favor or to disturb others.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),

                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "And then the cycle begins ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: RainbowText(
                                      text: "AGAIN",
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        " until we have a winner 👑                                                                       ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Class that lets you play a rainbow rotating text
// Cause why not
class RainbowText extends StatefulWidget {
  final String text;
  final double fontSize;

  const RainbowText({super.key, required this.text, this.fontSize = 16.0});

  @override
  RainbowTextState createState() => RainbowTextState();
}

class RainbowTextState extends State<RainbowText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _animation = Tween(begin: 0.0, end: 10.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: const [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
              ],
              stops: const [0.0, 0.166, 0.332, 0.498, 0.664, 0.83, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              tileMode: TileMode.mirror,
              transform: GradientRotation(_animation.value * 2 * 3.1416),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
