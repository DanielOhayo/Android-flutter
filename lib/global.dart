import 'package:flutter/material.dart';
import 'dart:async';

bool isDoneLevels = false;
bool val_ = false;
bool inHomePage = false;
var userName = '';

class Global {
  Future<void> openDialog(BuildContext context, String text) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
