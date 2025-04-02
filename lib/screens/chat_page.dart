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
    // Check if there's anything to send
    if (_controller.text.isEmpty && _selectedImage == null) return;

    try {
      String userMessage = _controller.text;
      File? image = _selectedImage;
      String? userImageUrl;

      // Show loading indicator if needed
      // setState(() { isLoading = true; });

      // Upload image if present and get URL
      if (image != null) {
        print("Uploading image: ${image.path}");
        userImageUrl = await GeminiService.uploadImageToStorage(image);

        if (userImageUrl == null || userImageUrl.isEmpty) {
          print("Warning: Image upload failed, continuing without image");
          // Optionally show a toast/snackbar to the user about the image upload failure
        } else {
          print("Image uploaded successfully: $userImageUrl");
        }
      }

      // Save user message with image URL if available
      await GeminiService.saveMessageToFirestore(userMessage, true, imageUrl: userImageUrl);

      // Clear input fields
      setState(() {
        _controller.clear();
        _selectedImage = null;
        // isLoading = false;
      });

      // Get response from Gemini
      String botResponse;
      if (image == null) {
        botResponse = await GeminiService.getResponseFromText(userMessage);
      } else {
        botResponse = await GeminiService.getResponseFromImage(image, userMessage);
      }

      // Save bot response
      await GeminiService.saveMessageToFirestore(botResponse, false);

    } catch (e) {
      print("Error in _sendMessage: $e");
      // Hide loading indicator
      // setState(() { isLoading = false; });

      // Optionally show error message to user
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Failed to send message: $e"))
      // );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? username = FirebaseAuth.instance.currentUser?.displayName;
    String userInitial = username != null && username.isNotEmpty ? username[0].toUpperCase() : "U";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "Nova AI",
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
                    bool isUser = message['isUser'] ?? false;

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black.withOpacity(0.14)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: isUser
                                      ? Colors.blue.withOpacity(0.26)
                                      : Colors.orange.withOpacity(0.26),
                                  child: Text(
                                    isUser ? userInitial : "N",
                                    style: TextStyle(
                                        color: isUser ? Colors.blue : Colors.orange,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                            SizedBox(height: 5),
                            if (message["imageUrl"] != null && message["imageUrl"].toString().isNotEmpty)
                              Container(
                                height: 200,
                                width: double.infinity,
                                margin: EdgeInsets.only(bottom: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    message["imageUrl"],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      print("Error loading image: $error");
                                      return Container(
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.error, color: Colors.red),
                                              SizedBox(height: 4),
                                              Text("Failed to load image",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            MarkdownBody(
                              data: message["text"] ?? "",
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
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
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