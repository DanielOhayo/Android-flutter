import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_dev/utilities/constant.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dev/Screens/login_screen.dart';
import 'package:flutter_dev/Screens/homePage_screen.dart';
import 'package:flutter_dev/Screens/voiceLearn_screen.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

class AudioList extends StatefulWidget {
  @override
  _AudioListState createState() => _AudioListState();
}

class _AudioListState extends State<AudioList> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    setAudio();
    // audioPlayer.onPlayerStateChanged.listen((state) {
    //   setState(() {
    //     isPlaying = state == PlayerState.PLAYING;
    //   });
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
    audioPlayer.setUrl('/data/user/0/com.example.flutter_dev/cache/audio');

    // final result = await FilePicker.platform.pickFiles();
    print('setAudio1');
  }

  @override
  void dispose() {
    audioPlayer.dispose();

    super.dispose();
  }

  Widget _buildbackBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.black),
        onPressed: () {
          print('Back Button Pressed');
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => VoiceLearn()));
        },
        child: Text(
          'Back (to home page)',
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
              'The Flutter Audio',
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
                    // print("here");

                    // await audioPlayer.play(source);
                    await audioPlayer.resume();
                  }
                },
              ),
            ),
            _buildbackBtn(),
          ],
        ),
      ));
}
