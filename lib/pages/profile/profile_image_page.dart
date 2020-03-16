import 'dart:io';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../providers/profile_provider.dart';

class ProfileImagePreview extends StatefulWidget {
  final File image;

  ProfileImagePreview(this.image);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProfileImageProvider();
  }
}

class _ProfileImageProvider extends State<ProfileImagePreview> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: isLoading
            ? PreferredSize(child: Container(), preferredSize: Size(0, 0))
            : AppBar(
                backgroundColor: Colors.black,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await Provider.of<ProfileProvider>(context, listen: false)
                          .updateProfileImage(widget.image);
                      isLoading = false;
                      Fluttertoast.showToast(
                          msg: "Display picture updated",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIos: 1,
                          backgroundColor: Colors.grey,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            Center(
              child: Image.file(
                widget.image,
                height: 500,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Center(
              child: isLoading ? CircularProgressIndicator() : Container(),
            ),
          ],
        ));
  }
}
