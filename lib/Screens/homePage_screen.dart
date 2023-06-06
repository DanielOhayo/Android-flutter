import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dev/Screens/login_screen.dart';
import 'package:flutter_dev/Screens/voiceLearn_screen.dart';
import '../global.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dev/Screens/recordingState.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController emerNumController = TextEditingController();

  late SharedPreferences prefs;
  Global global = new Global();
  List<Widget> textFields = [];

  Future openDialogVoiceLearn(text) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(text),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VoiceLearn()));
              },
            ),
          ],
        ),
      );

  Future openDialogEmerNum() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            TextField(
                controller: emerNumController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                )),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                submitEmerNum();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );

  bool CheckLevelsForListening() {
    //check if done the levels - by global index
    if (!isDoneLevels) {
      global.openDialog(context, "you need to done all level of recognize");
      return false;
    }
    return true;
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
      padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 35.0),
      width: double.maxFinite,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.black),
        onPressed: () {
          print('Voice Learn Button Pressed');
          if (isDoneLevels) {
            openDialogVoiceLearn(
                "Your voice is already learned, do you want to relearn?");
          } else {
            inHomePage = false;

            Navigator.push(
                context, MaterialPageRoute(builder: (context) => VoiceLearn()));
          }
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

  void submitEmerNum() async {
    print("gg");
    var reqBody = {
      "email": userName,
      "emergencyNumber": emerNumController.text,
    };
    var response = await http.post(Uri.parse(emergencyNum),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody));
    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      print("yes");
    } else {
      print("no");
    }
  }

  Widget _buildChangeEmerNumBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 35.0),
      width: double.maxFinite,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.black),
        onPressed: () {
          openDialogEmerNum();
          print('ChangeEmerNum button Pressed');
        },
        child: Text(
          'Modify emergency number',
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
        icon: Icon(Icons.logout_outlined),
        iconSize: 50,
        onPressed: () async {
          inHomePage = false;

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    inHomePage = true;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 115, 174, 245),
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Consumer<RecordingState>(
          builder: (context, recordingState, _) {
            return Text(
              recordingState.isRecording ? 'Listening ...' : 'Not Listening',
              style: TextStyle(fontSize: 24),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CupertinoSwitch(
              trackColor: Colors.grey,
              activeColor: Colors.green,
              value: val_,
              onChanged: (newValue) {
                if (CheckLevelsForListening()) {
                  if (CheckLevelsForListening()) {
                    final recordingState =
                        Provider.of<RecordingState>(context, listen: false);
                    if (recordingState.isRecording) {
                      recordingState.stopRecording();
                    } else {
                      recordingState.startRecording(context);
                    }
                    if (recordingState.isRecording == true) {
                      newValue = false;
                      print("dani off");
                    } else {
                      newValue = true;
                      print("dani on");
                    }
                    setState(() {
                      val_ = recordingState.isRecording;
                    });
                  }
                }
              }),
          _buildVoiceLearnBtn(),
          _buildChangeEmerNumBtn(),
          _buildbackBtn(),
        ],
      ),
    );
  }
}
