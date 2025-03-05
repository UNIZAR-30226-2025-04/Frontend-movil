import 'package:flutter/material.dart';

String selectedAvatar = 'pixelHeart';

void showProfile(BuildContext context) {
  final List<String> avatars = [
    'pixelHeart',
    'pixelPica',
    'pixelDiamond',
    'pixelTrebol',
    'pixelSoyi',
    'pixelBrat',
    'pixelBarb',
    'pixelBard',
  ];

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (
          BuildContext context,
          void Function(void Function()) setState,
        ) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Pop up border
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        //spacing: 50,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              //needed async to upload the profile picture
                              final newAvatar = await showIconPickerDialog(
                                context,
                                avatars,
                                selectedAvatar,
                              );
                              if (newAvatar != null) {
                                setState(() {
                                  selectedAvatar = newAvatar;
                                });
                              }
                            },
                            child: CircleAvatar(
                              radius: 75,
                              backgroundColor: Colors.white,
                              child: _buildAvatarImage(selectedAvatar),
                            ),
                          ),

                          Expanded(
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                // Username field
                                TextField(
                                  controller: usernameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Username',
                                    labelStyle: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF353A50),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.blueAccent,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Password field
                                TextField(
                                  controller: passwordController,
                                  style: const TextStyle(color: Colors.white),
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF353A50),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.blueAccent,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),
                                // Repeat Password Field
                                TextField(
                                  controller: repeatPasswordController,
                                  style: const TextStyle(color: Colors.white),
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Repeat your password',
                                    labelStyle: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF353A50),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.blueAccent,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Acciones para "Change"
                              // Por ejemplo, guardar el perfil
                            },
                            child: const Text('Change'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            onPressed: () {
                              // Acciones para "Log off"
                            },
                            child: const Text('Log off'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            onPressed: () {
                              // Acción para "Cancel"
                              // Por ejemplo, Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

// Pop-up to choose between several icons
Future<String?> showIconPickerDialog(
  BuildContext context,
  List<String> avatars,
  String currentAvatar,
) {
  return showDialog<String?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Elige tu ícono"),
        content: SizedBox(
          width: 400,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                avatars.map((avatar) {
                  return GestureDetector(
                    onTap: () {
                      selectedAvatar = avatar;
                      // Al tocar un ícono, volvemos con ese valor
                      Navigator.pop(context, avatar);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: _buildAvatarImage(avatar),
                        ),
                        const SizedBox(height: 5),
                        Text(avatar),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  );
}

// Returns the image selected in avatarName
Widget _buildAvatarImage(String avatarName) {
  switch (avatarName) {
    case 'pixelHeart':
      return Image.asset('images/pixelHeart.png');
    case 'pixelPica':
      return Image.asset('images/pixelPica.png');
    case 'pixelDiamond':
      return Image.asset('images/pixelDiamond.png');
    case 'pixelTrebol':
      return Image.asset('images/pixelTrebol.png');
    case 'pixelSoyi':
      return Image.asset('images/pixelSoyi.png');
    case 'pixelBrat':
      return Image.asset('images/pixelBrat.png');
    case 'pixelBarb':
      return Image.asset('images/pixelBarb.png');
    case 'pixelBard':
      return Image.asset('images/pixelBard.png');
    default:
      return const Icon(Icons.person, size: 36);
  }
}
