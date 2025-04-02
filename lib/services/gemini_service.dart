import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("Error: No user logged in");
        return null;
      }

      // Get file extension
      String fileExtension = path.extension(image.path);
      if (fileExtension.isEmpty) {
        fileExtension = '.jpg'; // Default extension
      }

      // Create a unique filename
      String fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      // Create a reference to the location where the file will be uploaded
      // Make sure this path exists and is accessible in your Firebase Storage rules
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('chat_images')
          .child(fileName);

      // Create upload task
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': user.uid},
      );

      // Start upload
      print("Starting upload to ${ref.fullPath}");
      UploadTask uploadTask = ref.putFile(image, metadata);

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      String url = await snapshot.ref.getDownloadURL();
      print("Upload successful. Download URL: $url");

      return url;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  static Future<void> saveMessageToFirestore(String text, bool isUser, {String? imageUrl}) async {
    try {
      String userUID = FirebaseAuth.instance.currentUser!.uid;
      CollectionReference messagesRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(userUID)
          .collection('messages');

      Map<String, dynamic> messageData = {
        'text': text,
        'isUser': isUser,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Only add imageUrl if it exists
      if (imageUrl != null && imageUrl.isNotEmpty) {
        messageData['imageUrl'] = imageUrl;
        print("Adding image URL to Firestore document: $imageUrl");
      }

      DocumentReference docRef = await messagesRef.add(messageData);
      print("Message saved to Firestore with ID: ${docRef.id}");

      // Verify the document was saved correctly
      DocumentSnapshot doc = await docRef.get();
      print("Saved document data: ${doc.data()}");
    } catch (e) {
      print("Error saving message to Firestore: $e");
    }
  }
}