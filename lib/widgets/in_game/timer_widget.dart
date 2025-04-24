import 'package:flutter/material.dart';
import 'dart:async';

/// A widget that displays a countdown timer.
class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key, required this.timeout});
  final int timeout;
  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  /// Timer duration in seconds.
  late int _seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _seconds = widget.timeout;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeout != widget.timeout) {
      _resetTimer(widget.timeout);
    }
  }

  /// Reset the timer
  void _resetTimer(int newTimeout) {
    setState(() {
      _seconds = newTimeout;
    });
    _startTimer();
  }

  /// Starts the countdown timer.
  void _startTimer() {
    _timer?.cancel(); // Cancel previous timers
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        timer.cancel(); // Detiene cuando llega a 0
      }
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
