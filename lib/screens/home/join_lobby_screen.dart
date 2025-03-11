import 'package:flutter/material.dart';
//import 'package:nogler/dio/dio_client.dart';
//import 'package:flutter/services.dart';
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
  bool hasFetched = false;

  //TODO, lista provisional para comprobar la estructura de la lista
  List<String> lobbyUsers = [
    "Jogue",
    "Emilliano",
    "Nicock",
    "YagoAndTheYagos",
    "Victor Bodrios",
    "Ruben",
    "Jota",
    "Josemi",
  ];

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        if (!hasFetched) {
          hasFetched = true;
          /* TODO, hacer comunicacion con el backend
          Future.delayed(Duration.zero, () async {
            final data = await _getPublicLobbies();
          });
          */
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
                  child: ListView.builder(
                    padding: EdgeInsets.all(12.5),
                    itemCount: lobbyUsers.length,
                    itemBuilder: (context, index) {
                      return LobbieBox(
                        playerName: lobbyUsers[index],
                        playerIcon: 6,
                        lobbyOcupation: 4,
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

//TODO, hacer cuando este la conexion con el backend
/* 
Future<List<Map<String, dynamic>>> _getPublicLobbies() async {
  final dioClient = DioClient();
  try {
    final response = await dioClient.dio.get();
  }
  return [];
}
*/
