import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nogler',
      home: Scaffold(
        appBar: AppBar(title: const Text('Nogler')),
        body: const Center(child: Text('Hola mundo')),
      ),
    );
  }
}
