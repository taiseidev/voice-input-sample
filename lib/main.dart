import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STT Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const STT(),
    );
  }
}

class STT extends StatefulWidget {
  const STT({Key? key}) : super(key: key);

  @override
  _STTState createState() => _STTState();
}

class _STTState extends State<STT> {
  String lastWords = "";
  String lastError = '';
  String lastStatus = '';
  bool listen = false;
  stt.SpeechToText speech = stt.SpeechToText();

  Future<void> _speak() async {
    bool available = await speech.initialize(
      onError: errorListener,
      onStatus: statusListener,
    );
    if (available) {
      speech.listen(
        onResult: resultListener,
        localeId: 'ja',
      );
    } else {
      print("The user has denied the use of speech recognition.");
    }
  }

  Future<void> _stop() async {
    speech.stop();
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STT Sample'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(lastWords),
                if (lastWords.isNotEmpty && lastStatus == 'done')
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          return AlertDialog(
                            content: TextFormField(
                              initialValue: lastWords,
                              onChanged: (value) {
                                setState(() {
                                  lastWords = value;
                                });
                              },
                            ),
                            actions: [
                              ElevatedButton(
                                child: const Text("完了"),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('編集'),
                  ),
              ],
            ),
            if (lastStatus == 'listening')
              Lottie.network(
                  'https://assets3.lottiefiles.com/packages/lf20_8q6gmpci.json')
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              listen = !listen;
              listen ? _speak() : _stop();
            },
            child:
                listen ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
          ),
          const SizedBox(
            width: 8,
          ),
          if (lastWords.isNotEmpty && lastStatus == 'done')
            FloatingActionButton(
              onPressed: () {},
              child: const Text('登録'),
            ),
        ],
      ),
    );
  }
}
