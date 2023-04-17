import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_dev/utilities/constant.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dev/Screens/login_screen.dart';
import 'package:flutter_dev/Screens/voiceLearn_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:microphone/microphone.dart';

import 'dart:io';
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false;
  late SharedPreferences prefs;
  bool val_ = true;
  //for recording
  FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  int _recordingDuration = 5; // duration of the recording in seconds
  StreamSubscription<List<int>>? _microphoneStreamSubscription;
  bool _isRecording = false;
  final microphoneRecorder = MicrophoneRecorder()..init();

  void onChangeMethod_(newVal1) {
    setState(() {
      val_ = newVal1;
    });
    if (val_ == true) {
      StartRecordLoop();
    } else {
      StopRecordLoop();
    }
  }

  void StartRecordLoop() async {
    // request permission to access the device's microphone

    await Permission.microphone.request();

    // start recording
    await _audioRecorder.openAudioSession();
    microphoneRecorder.init();

    microphoneRecorder.start();
    _audioRecorder.startRecorder(toFile: 'audio_5_sec.aac');

    // schedule the recording to stop after the specified duration
    _isRecording = true;
    print("record background");
    Timer(Duration(seconds: _recordingDuration), () {
      // call py script with input "C:\Users\ohayo\AppData\Local\Google\AndroidStudio2022.1\device-explorer\samsung-sm_g960f-2ab8a93c423f7ece\data\data\com.example.flutter_dev\cache\audio_5_sec.aac"
      print("stop record background");

      StopRecordLoop();
    });
  }

  void StopRecordLoop() async {
    await _audioRecorder.stopRecorder();
    await _audioRecorder.closeAudioSession();
    await _microphoneStreamSubscription?.cancel();
    _microphoneStreamSubscription = null;
    _isRecording = false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  Widget _buildVoiceLearnBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.black),
        onPressed: () {
          print('Voice Learn Button Pressed');
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => VoiceLearn()));
        },
        child: Text(
          'Voice learn',
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
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        },
      ),
    );
  }

  Widget _buildOnOffBtn(String text, bool val, Function onChangeMethod) {
    return Padding(
      padding: EdgeInsets.only(top: 22.0, left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                color: Colors.black),
          ),
          Spacer(),
          CupertinoSwitch(
              trackColor: Colors.grey,
              activeColor: Colors.green,
              value: val,
              onChanged: (newValue) {
                if (val_ == true) {
                  newValue = false;
                  print("dani off");
                } else {
                  newValue = true;
                  print("dani on");
                }
                onChangeMethod(newValue);
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Home Page',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30.0),
                      SizedBox(
                        height: 30.0,
                      ),
                      _buildOnOffBtn("on/off", val_, onChangeMethod_),
                      _buildVoiceLearnBtn(),
                      _buildbackBtn(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
