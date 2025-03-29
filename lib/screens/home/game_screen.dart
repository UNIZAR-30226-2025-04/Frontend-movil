import 'package:flutter/material.dart';
import 'package:nogler/widgets/action_buttons_widget.dart';
import 'package:nogler/widgets/background_widget.dart';
import 'package:nogler/widgets/deck_info_widget.dart';
import 'package:nogler/widgets/hand_navigation_widget.dart';
import 'package:nogler/widgets/joker_cards_widget.dart';
import 'package:nogler/widgets/main_cards_widget.dart';
import 'package:nogler/widgets/selected_cards_widget.dart';
import 'package:nogler/widgets/setting_button_widget.dart';
import 'package:nogler/widgets/sidebar_widget.dart';
import 'package:nogler/widgets/timer_widget.dart';

/// Represents the main game screen with UI components for gameplay.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Stack(
            children: [
              // Main row containing the Sidebar and game UI elements
              Row(
                children: [
                  Sidebar(), // Sidebar for navigation and game info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Section for the Joker cards at the top left
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.start, // Aligns JokerCards to the left
                            children: [JokerCards()],
                          ),
                        ),
                        
                        SelectedCards(), // Widget displaying selected cards
                        SizedBox(height: 5),
                        
                        // MainCards widget in the center
                        MainCards(),
                        SizedBox(height: 5),
                        
                        // Navigation buttons for handling hand movement
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 10),
                            HandNavigation(),
                          ],
                        ),
                        
                        // Action buttons and deck info at the bottom
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 120),
                            ActionButtons(), // Game action buttons
                            SizedBox(width: 60),
                            DeckInfo(), // Displays deck-related information
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Timer and settings button placed at the top right
              TimerWidget(),
              SettingsButton(),
            ],
          ),
        ),
      ),
    );
  }
}

