import 'package:chat_messenger/components/chat_bubble.dart';
import 'package:chat_messenger/components/my_text_field.dart';
import 'package:chat_messenger/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatPage(
      {Key? key, required this.receiverUserEmail, required this.receiverUserID})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    // only send message if text isnt empty
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
        backgroundColor: Colors.grey[700],
      ),
      body: Column(
        children: [
          //messages
          Expanded(
            child: _buildMessageList(),
          ),

          //user input
          _buildMessageInput(),
        ],
      ),
    );
  }

  //build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          _firebaseAuth.currentUser!.uid, widget.receiverUserID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading..');
        }

        return ListView(
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //align the messages tgo the right and if the sender is the cufrrent user, otherwise
    //to the left

    var isOwnUser = (data['senderId'] == _firebaseAuth.currentUser!.uid);

    var alignment = isOwnUser ? Alignment.centerRight : Alignment.centerLeft;

    var crossAxisAlignment =
        isOwnUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    var mainAxisAlignment =
        isOwnUser ? MainAxisAlignment.end : MainAxisAlignment.start;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          children: [
            Text(data['senderEmail']),
            const SizedBox(height: 5.0),
            ChatBubble(
              message: data['message'],
              isOwnUser: isOwnUser,
            ),
          ],
        ),
      ),
    );
  }

  //build message input
  Widget _buildMessageInput() {
    return Row(
      children: [
        //text field
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyTextField(
              controller: _messageController,
              hintText: 'Enter Message',
              obscureText: false,
            ),
          ),
        ),
        //send button
        IconButton(
          onPressed: sendMessage,
          icon: const Icon(Icons.arrow_upward, size: 40),
        ),
      ],
    );
  }
}
