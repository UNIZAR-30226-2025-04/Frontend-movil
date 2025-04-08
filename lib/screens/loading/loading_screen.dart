import 'package:flutter/material.dart';
import 'package:nogler/widgets/background_widget.dart';

/// A screen that shows a loading indicator with a customizable message.
class LoadingScreen extends StatelessWidget {
  // The message to display below the loading indicator.
  final String loadingMessage;

  const LoadingScreen({super.key, required this.loadingMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // The loading spinner
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              // The custom loading message
              Text(
                loadingMessage,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
