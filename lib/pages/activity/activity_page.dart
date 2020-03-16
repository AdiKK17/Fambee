import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserActivityPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _UserActivityPage();
  }
}

class _UserActivityPage extends State<UserActivityPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Activity"),
      ),
      body: Center(
        child: Text(
          "Activity is not currently available!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, color: Colors.grey),
        ),
      ),
    );
  }
}
