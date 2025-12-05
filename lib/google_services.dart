import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = "AIzaSyBsDWyPFb1RndpBfmz9m6ZarNv9zK5WTU4";

  Future<String> sendMessage(String message) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$apiKey",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": message}
            ]
          }
        ]
      }),
    );

    final data = jsonDecode(response.body);
    print("GEMINI RESPONSE: $data");

    // API error
    if (data["error"] != null) {
      return "API Error: ${data["error"]["message"]}";
    }

    // Standard Gemini response
    try {
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } catch (_) {}

    // output_text fallback
    try {
      return data["candidates"][0]["output_text"];
    } catch (_) {}

    return "⚠️ Unexpected API response.";
  }



}












