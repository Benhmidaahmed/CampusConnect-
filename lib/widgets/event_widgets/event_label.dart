import 'package:flutter/material.dart';

class EventLabel extends StatelessWidget {
  final String text;

  const EventLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF333333),
      ),
    );
  }
}