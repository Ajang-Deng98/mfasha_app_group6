import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/gemini_service.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  File? _selectedImage;
  String userUID = FirebaseAuth.instance.currentUser!.uid;

  void _sendMessage() async {
    if (_controller.text.isEmpty && _selectedImage == null) return;

    String userMessage = _controller.text;
    File? image = _selectedImage;
    String? imageUrl;

    if (image != null) {
      imageUrl = await GeminiService.uploadImageToStorage(image);
    }

    await GeminiService.saveMessageToFirestore(userMessage, true, imageUrl: imageUrl);
    setState(() {
      _controller.clear();
      _selectedImage = null;
    });

    String botResponse = image == null
        ? await GeminiService.getResponseFromText(userMessage)
        : await GeminiService.getResponseFromImage(image, userMessage);

    await GeminiService.saveMessageToFirestore(botResponse, false, imageUrl: null);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "Nova AI",  // Your new title
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(userUID)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index].data() as Map<String, dynamic>;
                    bool isUser = message['isUser'];

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black.withOpacity(0.14)), // 24% opacity black border
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUser)
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.orange.withOpacity(0.26),
                                    child: Text("N", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(width: 8),
                                ],
                              ),
                            if (message["imageUrl"] != null)
                              Image.network(message["imageUrl"], height: 100, width: 100, fit: BoxFit.cover),
                            MarkdownBody(
                              data: message["text"],
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _selectedImage != null
              ? Padding(
            padding: EdgeInsets.all(8.0),
            child: Image.file(_selectedImage!, height: 100),
          )
              : SizedBox.shrink(),
          Row(
            children: [
              IconButton(icon: Icon(Icons.image), onPressed: _pickImage),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: "Ask something..."),
                ),
              ),
              IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
            ],
          ),
        ],
      ),
    );
  }
}