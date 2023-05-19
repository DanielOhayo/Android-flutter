import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:microphone/microphone.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dev/Screens/login_screen.dart';
import 'package:flutter_dev/Screens/voiceLearn_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:microphone/microphone.dart';
import '../global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dev/Screens/recordingState.dart';
import 'package:flutter_dev/Screens/voiceLearn_screen.dart';

import 'dart:io';
import 'dart:async';

class RecordingState extends ChangeNotifier {
  bool _isRecording = false;
  int _recordingDuration = 5; // duration of the recording in seconds
  bool get isRecording => _isRecording;
  FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final microphoneRecorder = MicrophoneRecorder()..init();
  StreamSubscription<List<int>>? _microphoneStreamSubscription;
  // Future openDialog(text) => showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Text(text),
  //         actions: [
  //           TextButton(
  //             child: Text('close'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       ),
  //     );

  void EmotionRcognition() async {
    var reqBody = {
      "email": "",
    };
    var response = await http.post(Uri.parse(emotion),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody));
    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      print(jsonResponse['success']);
      String emotion = "fear"; ////replace in th response from server
      //replace in the user name from db
      if (emotion == "fear") {
        // openDialog("you are in danger");
      }
    } else {
      print('Something went wrong');
    }
  }

  void RecognitionUserVoice() async {
    var reqBody = {
      "email": userName,
      "file": "audio_5_sec.aac",
    };
    var response = await http.post(Uri.parse(recognize),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody));
    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      print("your voice recognize with name ${userName}, it's you?");
      EmotionRcognition();
    } else {
      print('Something went wrong');
    }
  }

  Future<void> startRecording() async {
    _isRecording = true;
    await Permission.microphone.request();
    // start recording
    await _audioRecorder.openAudioSession();
    microphoneRecorder.init();

    microphoneRecorder.start();
    _audioRecorder.startRecorder(toFile: 'audio_5_sec.aac');
    await Future.delayed(Duration(seconds: 5));
    await _audioRecorder.stopRecorder();
    await _audioRecorder.closeAudioSession();
    RecognitionUserVoice();
    await Future.delayed(Duration(seconds: 60));
    // schedule the recording to stop after the specified duration

    print("record background");

    // Timer(Duration(seconds: _recordingDuration), () async {
    //   // Stop recording
    //   await _audioRecorder.stopRecorder();
    //   // Pause for 5 seconds
    //   await Future.delayed(Duration(seconds: 5));
    //   //   print("stop record background");
    //   //   // RecognitionUserVoice();
    //   _audioRecorder.startRecorder(toFile: 'audio_5_sec.aac');
    // });
    notifyListeners();
    if (_isRecording) {
      await startRecording();
    }
  }

  void stopRecording() async {
    _isRecording = false;
    await _audioRecorder.stopRecorder();
    await _audioRecorder.closeAudioSession();
    await _microphoneStreamSubscription?.cancel();
    _microphoneStreamSubscription = null;
    notifyListeners();
  }
}
