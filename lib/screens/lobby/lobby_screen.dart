import 'package:flutter/material.dart';
import 'package:nogler/screens/home/home_screen.dart';
import 'package:nogler/widgets/background_widget.dart';
import 'package:nogler/widgets/player_box.dart';
import 'package:page_transition/page_transition.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreen();
}

class _LobbyScreen extends State<LobbyScreen> {
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
    return Scaffold(
      body: BackgroundWidget(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Title of page, lobby
                Text(
                  'LOBBY',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                //Number o f participants
                Text(
                  '8 / 8',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),

                //TODO, boton de public para poder cambiar entre private y public

                //Code of the lobby
                Text(
                  'Code: 1234',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),

                //TODO, botones copy, share y abrir chat de sala
              ],
            ),

            //User distribution
            Expanded(
              child: Align(
                alignment: const Alignment(0, -0.5),
                child: Stack(
                  fit: StackFit.loose,
                  alignment: Alignment.topLeft,
                  children: [
                    GridView.builder(
                      shrinkWrap: true,

                      padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 20,
                        bottom: 0,
                      ),

                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200, //width of the player's box
                        crossAxisSpacing: 12,
                        mainAxisExtent: 100, //height of the player's box
                        mainAxisSpacing: 12,
                        childAspectRatio: 3,
                      ),
                      itemCount: lobbyUsers.length,
                      itemBuilder: (context, index) {
                        return PlayerBox(
                          playerName: lobbyUsers[index],
                          playerIcon: 1, //TODO, conexion con base de datos
                          isHost:
                              lobbyUsers[index] ==
                              'Jogue', //TODO, conexion con base de datos
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            //Leave lobby button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
                child: Text('Leave', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
