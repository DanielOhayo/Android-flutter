import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dev/Screens/voiceLearn_screen.dart';
import 'package:flutter_dev/Screens/checkRecognition.dart';
import 'dart:async';

// final pathToReadAudio = '/data/user/0/com.example.flutter_dev/cache/audio';

class AudioList extends StatefulWidget {
  @override
  _AudioListState createState() => _AudioListState();
}

class _AudioListState extends State<AudioList> {
  final audioPlayer = AudioPlayer();
  TextEditingController feedbackController = TextEditingController();

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
    setAudio();

    // audioPlayer.onPlayerStateChanged.listen((state) {
    //   setState(() {
    //     isPlaying = state == PlayerState.PLAYING;
    // });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onAudioPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  Future setAudio() async {
    final pathToReadAudio =
        'data/user/0/com.example.flutter_dev/cache/audio.aac';
    audioPlayer.setUrl(pathToReadAudio);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future openDialog(text) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(text),
          actions: [
            TextButton(
              child: Text('close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('check if recognize me'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CheckRecognition()));
              },
            )
          ],
        ),
      );

  void Voice2DB_script() async {
    var reqBody = {
      "email": "dani", //TODO: take email from db
    };
    var response = await http.post(Uri.parse(recognizeDB),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody));
    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      print(jsonResponse['success']);
      openDialog("Your voice added to DB");
    } else {
      print('Something went wrong');
      openDialog("Somthing went wrong, try again");
    }
  }

  void Emotion_script() async {
    var reqBody = {
      "email": feedbackController.text,
    };
    var response = await http.post(Uri.parse(emotion),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody));
    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      print(jsonResponse['success']);
    } else {
      print('Something went wrong');
    }
  }

  Widget _buildVoice2DBBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Color.fromARGB(255, 115, 174, 245)),
        onPressed: () {
          print("you press on Rcognition button");
          Voice2DB_script();
        },
        child: Text(
          'Add my voice to DB',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Color.fromARGB(255, 115, 174, 245)),
        onPressed: () {
          print("you press on Emotion Rcognition button");
          Emotion_script();
        },
        child: Text(
          'Check my emotion',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _buildbackBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: IconButton(
        icon: Icon(Icons.arrow_back),
        iconSize: 50,
        onPressed: () async {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => VoiceLearn()));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
            ),
            const Text(
              'My Recored Audio',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.toDouble(),
              onChanged: (value) async {
                Duration(seconds: value.toInt());
                await audioPlayer.seek(position);

                await audioPlayer.resume();
                setState(() {});
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(position.toString()),
                  Text(duration.toString()),
                ],
              ),
            ),
            CircleAvatar(
              radius: 35,
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                iconSize: 50,
                onPressed: () async {
                  if (isPlaying) {
                    await audioPlayer.pause();
                  } else {
                    await audioPlayer.resume();
                  }
                },
              ),
            ),
            _buildVoice2DBBtn(),
            // _buildEmotionBtn(),
            _buildbackBtn(),
          ],
        ),
      ));
}
