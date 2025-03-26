import 'package:flutter/material.dart';
import 'package:nogler/data/api/join_lobby_api.dart';
import 'package:nogler/screens/home/home_screen.dart';
import 'package:nogler/widgets/background_widget.dart';
import 'package:nogler/widgets/lobbie_box.dart';
import 'package:page_transition/page_transition.dart';

class JoinLobbyScreen extends StatefulWidget {
  const JoinLobbyScreen({super.key});

  @override
  State<JoinLobbyScreen> createState() => _JoinLobbyScreen();
}

class _JoinLobbyScreen extends State<JoinLobbyScreen> {
  List<Map<String, dynamic>> lobbies = [];
  bool hasFetched = false; // To ensure the data is fetched only once
  bool isLoading = true; // Flag to track loading state

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        if (!hasFetched) {
          hasFetched = true;
          Future.delayed(Duration.zero, () async {
            // Fetch the friends list from the API
            final data = await getAllLobbies(); // Function to fetch friends
            if (context.mounted) {
              setState(() {
                lobbies = List.from(data);
                isLoading = false; // Set loading to false once data is fetched
              });
            }
          });
        }
        return Scaffold(
          body: BackgroundWidget(
            child: Column(
              children: [
                //Screen's title
                Text(
                  'Public lobbies',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    //Add some space between
                    SizedBox(width: 10),

                    //Insert code button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        "Insert Code",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    //Add some space between
                    SizedBox(width: 20),

                    //Matchmaking button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        "Matchmaking",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                //Add some space between
                SizedBox(height: 10),

                //lobbies list
                Expanded(
                  child: // Show loading indicator while data is being fetched
                      isLoading
                          ? const Center(
                            child:
                                CircularProgressIndicator(), // Show loading spinner
                          )
                          : lobbies.isEmpty
                          ? Center(
                            child: Text(
                              'No lobbies available', // Message when no data is available
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: EdgeInsets.all(12.5),
                            itemCount: lobbies.length,
                            itemBuilder: (context, index) {
                              String username =
                                    lobbies[index]['creator_username'];
                                int iconId = lobbies[index]['host_icon'];
                                String lobbyId =
                                    lobbies[index]['lobby_id'];
                                 int numberOfPlayers =
                                          lobbies[index]['player_count'] ?? 0;
                              return LobbieBox(
                                playerName: username,
                                playerIcon: iconId,
                                lobbyOcupation: numberOfPlayers,
                                lobbyCode: lobbyId,
                              );
                            },
                          ),
                ),
                //Add some space between
                SizedBox(height: 10),

                //Back button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: const HomeScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Back",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    //Add some space between
                    SizedBox(width: 12.5),
                  ],
                ),
                //Add some space between
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
