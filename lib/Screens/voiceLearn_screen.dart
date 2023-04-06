import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_dev/utilities/constant.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dev/Screens/login_screen.dart';
import 'package:flutter_dev/Screens/homePage_screen.dart';
import 'package:flutter_dev/Screens/audioList_screen.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class VoiceLearn extends StatefulWidget {
  @override
  _VoiceLearnState createState() => _VoiceLearnState();
}

class _VoiceLearnState extends State<VoiceLearn> {
  final recorder = FlutterSoundRecorder();

  bool isRecorderReady = false;

  @override
  void initState() {
    initRecorder();

    super.initState();
  }

  @override
  void dispose() {
    recorder.closeRecorder();

    super.dispose();
  }

  void initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }

    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }

  Future record() async {
    await recorder.startRecorder(toFile: 'audio');
    print("Recordddddddd");
  }

  Future stop() async {
    if (!isRecorderReady) return;
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);

    print('Recorde audio: $audioFile');
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
              context, MaterialPageRoute(builder: (context) => HomePage()));
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

  Widget _buildPlayBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.black),
        onPressed: () {
          print('Back Button Pressed');
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AudioList()));
        },
        child: Text(
          'play',
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
      backgroundColor: Colors.grey.shade900,
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        StreamBuilder<RecordingDisposition>(
          stream: recorder.onProgress,
          builder: (context, snapshot) {
            final duration =
                snapshot.hasData ? snapshot.data!.duration : Duration.zero;
            String twoDigits(int n) => n.toString().padLeft(2, "0");
            final twoDigitsMinutes =
                twoDigits(duration.inMinutes.remainder(60));
            final twoDigitsSeconds =
                twoDigits(duration.inSeconds.remainder(60));

            return Text(
              '$twoDigitsMinutes:$twoDigitsSeconds',
              style: const TextStyle(
                fontSize: 80,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          child: Icon(
            recorder.isRecording ? Icons.stop : Icons.mic,
            size: 80,
          ),
          onPressed: () async {
            if (recorder.isRecording) {
              await stop();
            } else {
              await record();
            }
            recorder.isRecording
                ? print('Record Button Pressed')
                : print('Stop Button Pressed');
            setState(() {});
          },
        ),
        _buildPlayBtn(),
        _buildbackBtn(),
      ])));
}
