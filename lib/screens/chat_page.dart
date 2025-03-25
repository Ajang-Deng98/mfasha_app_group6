import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/gemini_service.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  File? _selectedImage;

  void _sendMessage() async {
    if (_controller.text.isEmpty && _selectedImage == null) return;

    String userMessage = _controller.text;
    File? image = _selectedImage;

    setState(() {
      _messages.add({"text": userMessage, "isUser": true, "image": image});
      _controller.clear();
      _selectedImage = null;
    });

    String botResponse = image == null
        ? await GeminiService.getResponseFromText(userMessage)
        : await GeminiService.getResponseFromImage(image, userMessage);

    setState(() {
      _messages.add({"text": botResponse, "isUser": false});
    });
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
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: message['isUser'] ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message["image"] != null)
                          Image.file(message["image"], height: 100, width: 100, fit: BoxFit.cover),
                        Text(message["text"], style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
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