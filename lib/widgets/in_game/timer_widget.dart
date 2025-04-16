import 'package:flutter/material.dart';
import 'dart:async';

/// A widget that displays a countdown timer.
/// The timer starts at 30 seconds and resets when it reaches 0.
class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  /// Timer duration in seconds.
  int _seconds = 30;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Starts the countdown timer.
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _seconds = 30; // Reset timer when it reaches 0
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 40,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          "$_seconds s",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
