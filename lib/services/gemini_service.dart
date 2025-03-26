import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';  // <-- Add this import

class GeminiService {
  static const String apiKey = "AIzaSyBQ9bSaMD52HQhms1wx6ycgObbq1rs0bPs";
  static const String endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

  static Future<String> getResponseFromText(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"] ?? "No response";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Failed to connect: $e";
    }
  }

  static Future<String> getResponseFromImage(File image, String prompt) async {
    try {
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
                {"inline_data": {"mime_type": "image/png", "data": base64Image}}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"] ?? "No response";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Failed to connect: $e";
    }
  }

  static Future<String?> uploadImageToStorage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child("chat_images/$fileName");

      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      return null; // Return null if upload fails
    }
  }

  static Future<void> saveMessageToFirestore(String text, bool isUser, {String? imageUrl}) async {
    String userUID = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(userUID)
        .collection('messages');

    await messagesRef.add({
      'text': text,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
  }
}