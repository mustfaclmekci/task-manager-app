import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = "";
  bool _isLoading = false;

  final String _apiKey = "AIzaSyDd4lUcYwqV0iO1Qm82jy7vViB3YOrIg_c";

  Future<void> _askAI(String prompt) async {
    setState(() {
      _isLoading = true;
      _response = "";
    });

    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );

    final content = [
      Content.text("Sen bir görev planlama ve motivasyon asistanısın."),
      Content.text(prompt),
    ];

    final response = await model.generateContent(content);

    setState(() {
      _response = response.text ?? "Boş cevap geldi.";
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gemini AI Asistan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Bir şey sor...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _askAI(_controller.text),
              child: const Text("Sor"),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: SingleChildScrollView(
                      child: Text(_response),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
