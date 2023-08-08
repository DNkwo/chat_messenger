import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isOwnUser;
  const ChatBubble({Key? key, required this.message, required this.isOwnUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isOwnUser ? Colors.grey : Colors.blue,
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
