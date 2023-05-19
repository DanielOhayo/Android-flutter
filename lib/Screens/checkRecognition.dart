import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'package:flutter_dev/Screens/homePage_screen.dart';
import 'package:flutter_dev/Screens/audioList_screen.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../global.dart';

class CheckRecognition extends StatefulWidget {
  @override
  _CheckRecognitionState createState() => _CheckRecognitionState();
}

class _CheckRecognitionState extends State<CheckRecognition> {
  final recorder = FlutterSoundRecorder();
  bool isStoped = false;
  bool isRecorderReady = false;

  @override
  void initState() {
    initRecorder();

    super.initState();
  }

  @override
  void dispose() {
    recorder.closeAudioSession();
    super.dispose();
  }

  void initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }

    await recorder.openAudioSession();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }

  Future record() async {
    await recorder.startRecorder(toFile: 'audioCheck.aac');
  }

  Future stop() async {
    if (!isRecorderReady) return;
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
    isStoped = true;
    print('Recorde audio: $audioFile');
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
              context, MaterialPageRoute(builder: (context) => AudioList()));
        },
      ),
    );
  }

  Future openDialog(text) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(text),
          actions: [
            TextButton(
              child: Text('yes'),
              onPressed: () {
                isDoneLevels = true;
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
            TextButton(
              child: Text("no, I'll try again"),
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

  void Recognition_script() async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );
    var reqBody = {
      "email": userName,
      "file": "audioCheck.aac",
    };
    var response = await http.post(Uri.parse(recognize),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody));
    var jsonResponse = jsonDecode(response.body);
    Navigator.of(context).pop();
    if (jsonResponse['status']) {
      openDialog("your voice recognize with name ${userName}, it's you?");
    } else {
      openDialog('Something went wrong');
      print('Something went wrong');
    }
  }

  Widget _buildPlayBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.black),
        onPressed: !isStoped ? null : Recognition_script,
        child: Text(
          ' check if recognize me',
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
      backgroundColor: Color.fromARGB(255, 115, 174, 245),
      appBar: AppBar(
        title: Text('Check if recognize me'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                StreamBuilder<RecordingDisposition>(
                  stream: recorder.onProgress,
                  builder: (context, snapshot) {
                    final duration = snapshot.hasData
                        ? snapshot.data!.duration
                        : Duration.zero;
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
              ]))));
}
