import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp( const ImageBot() );

}

class ImageBot extends StatefulWidget {
  const ImageBot({Key? key}) : super(key: key);

  @override
  State<ImageBot> createState() => _ImageBotState();
}

class _ImageBotState extends State<ImageBot> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final textController = TextEditingController();
  String imageUrl = 'https://lightwidget.com/wp-content/uploads/local-file-not-found-480x488.png';

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text(
              'Create images with AI!',
              style: GoogleFonts.robotoMono(),
          ),
        ),
        body: Center(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Describe anything you want to generate an image of!',
                        hintStyle: GoogleFonts.robotoMono(
                          fontSize: 14
                        ),
                      ),
                      validator: (String? value) {
                        if(value == null || value.isEmpty) {
                          return 'Please enter some text!';
                        }
                        return null;
                      },
                      controller: textController,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String textResponse = await _generateTextResponse(textController.text);
                          setState(() {
                            imageUrl = _generateImage(textResponse) as String;
                          });
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent
                      ),
                        child: Text(
                            'Generate',
                            style: GoogleFonts.robotoMono(
                              textStyle: const TextStyle(
                                letterSpacing: .9
                              )
                            )
                        ),
                    ),
                  ),
                ),
                Image.network(
                  imageUrl,
                  fit: BoxFit.fill,
                ),
              ],
            ),
          ),
        ),
        
      )
    );
  }


  Future<void> _generateImage(String input) async {

    if(textController.text.isNotEmpty) {
      var url = Uri.https('api.openai.com', '/v1/images/generations');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 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'
      };

      var body = jsonEncode({
        "prompt": input,
        "size": "512x512"
      });

      var response = await http.post(url, headers: headers, body: body);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      List<dynamic> images = decodedResponse['data'];
      imageUrl = images[0]['url'];
      print("IMAGEM SETADA COM A URL: $imageUrl");
      return images[0]['url'];
    }
  }


  Future<String> _generateTextResponse(String input) async {
    var url = Uri.https('api.openai.com', '/v1/engines/davinci-codex/completions');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer YOUR_API_KEY'
    };

    var body = jsonEncode({
      "prompt": input,
      "max_tokens": 50,
      "n": 1,
      "stop": null,
      "temperature": 0.7
    });

    var response = await http.post(url, headers: headers, body: body);
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    List<dynamic> choices = decodedResponse['choices'];
    String textResponse = choices[0]['text'].trim();
    return textResponse;
  }

}
