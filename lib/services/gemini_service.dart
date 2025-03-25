import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'consts.dart'

;class GeminiService {
  static const String apiKey = "AIzaSyBQ9bSaMD52HQhms1wx6ycgObbq1rs0bPs";
  static const String endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

  // Function to send text queries
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

  // Function to send image queries
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
}