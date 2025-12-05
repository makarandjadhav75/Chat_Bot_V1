import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'google_services.dart';

void main() {
  runApp(const MyChatApp());
}

class MyChatApp extends StatelessWidget {
  const MyChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final gemini = GeminiService();
  bool isLoading = false;

  // Voice Input
  late stt.SpeechToText speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  sendMessage() async {
    final userMessage = controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": userMessage});
      controller.clear();
      isLoading = true;
    });

    final botReply = await gemini.sendMessage(userMessage);

    setState(() {
      messages.add({"role": "bot", "text": botReply});
      isLoading = false;
    });
  }

  // Voice Function
  void startListening() async {
    bool available = await speech.initialize();

    if (available) {
      setState(() => isListening = true);

      speech.listen(onResult: (val) {
        setState(() {
          controller.text = val.recognizedWords;
        });
      });
    }
  }

  void stopListening() {
    setState(() => isListening = false);
    speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My AI Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg["role"] == "user";

                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: TextStyle(
                          color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),

          if (isLoading) const CircularProgressIndicator(),

          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Text Field
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                        hintText: "Type or Speak...",
                        border: OutlineInputBorder()),
                  ),
                ),

                // Mic Button
                GestureDetector(
                  onLongPress: startListening,
                  onLongPressUp: stopListening,
                  child: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
                    color: isListening ? Colors.red : Colors.black,
                    size: 30,
                  ),
                ),

                // Send Button
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
