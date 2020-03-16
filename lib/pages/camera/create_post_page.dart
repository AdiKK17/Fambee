import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as imageLib;
import "package:photofilters/photofilters.dart";

//import '../providers/testing.dart';
import '../../providers/home_feed_provider.dart';
//import '../providers/auth_provider.dart';

class CameraPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CameraPage();
  }
}

class _CameraPage extends State<CameraPage> {
  File _imageFile;
  imageLib.Image _image;
  String fileName;
  TextEditingController _textEditingController = TextEditingController();
  var _isUploading = false;

//  File _videoFile;

//  Future<void> _getImage(BuildContext context, ImageSource source) async {
//    final _image = await ImagePicker.pickImage(source: source, maxWidth: 800);
//    setState(() {
//      _imageFile = _image;
//    });
//    print(_imageFile);
//    print("//////////////////////////");
//    print(_imageFile);
//  }

  Future<void> getImage(BuildContext context, ImageSource source) async {
    var imageFile = await ImagePicker.pickImage(source: source);
    _imageFile = imageFile;
    fileName = basename(imageFile.path);
    var image = imageLib.decodeImage(imageFile.readAsBytesSync());
    image = imageLib.copyResize(image, height: 400, width: 400);
    setState(() {
      _image = image;
    });
  }

//  Future<void> _getVideo(BuildContext context,ImageSource source) async {
//    final _video = await ImagePicker.pickVideo(source: source);
//    setState(() {
//      _videoFile = _video;
//    });
//  }

  Widget _buildCommentTextField() {
    return ListTile(
      leading: CircleAvatar(
        radius: 15,
        backgroundImage: AssetImage(
          "assets/trial1.jpg",
        ),
      ),
      title: TextFormField(
        controller: _textEditingController,
        decoration: InputDecoration.collapsed(hintText: "Add a Caption..."),
      ),
//      trailing: FlatButton(
//        padding: EdgeInsets.all(0),
//        onPressed: () {
//          if (_textEditingController.text == null) {
//            return;
//          }
//          Provider.of<TestingProvider>(context)
//              .addComment(_textEditingController.text);
//          _textEditingController.text = "";
//        },
//        child: Text("Post"),
//      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("New Post"),
      ),
      body: _isUploading
          ? Center(
              child: Text(
                "Uploading...",
                style: TextStyle(color: Colors.black54, fontSize: 30),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: _imageFile == null
                        ? Text(
                            "No Image Selected",
                            textAlign: TextAlign.center,
                          )
                        : Image.file(
                            _imageFile,
                            fit: BoxFit.cover,
                          ),
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.width * 1.2,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 1,
                          color: Colors.grey,
                          style: BorderStyle.solid),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          getImage(context, ImageSource.gallery);
                        },
                        child: Text("Use Gallery"),
                      ),
                      FlatButton(
                        onPressed: () {
                          getImage(context, ImageSource.camera);
                        },
                        child: Text("Use Camera"),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
//            FlatButton(
//              onPressed: () => _getImage(context, ImageSource.camera),
//              child: Text("Video"),
//            ),
                  _imageFile == null
                      ? Container()
                      : FlatButton(
                          onPressed: () async {
                            _imageFile = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PhotoFilterSelector(
                                    title: null,
                                    filters: presetFiltersList,
                                    image: _image,
                                    filename: fileName),
                              ),
                            );
                          },
                          child: Text("Apply Filters"),
                        ),
//            SizedBox(
//              height: 10,
//            ),
                  _imageFile == null
                      ? Text("Choose an Image!")
                      : Column(
                          children: <Widget>[
//                      Image.file(
//                        _imageFile,
//                        fit: BoxFit.cover,
//                        height: 400,
////                  alignment: Alignment.center,
//                        width: MediaQuery.of(context).size.width * 0.95,
//                      ),
//                      SizedBox(
//                        height: 10,
//                      ),
                            _buildCommentTextField(),
                            SizedBox(
                              height: 10,
                            ),
                            FlatButton(
                              onPressed: () async {
                                setState(() {
                                  _isUploading = true;
                                });
                                await Provider.of<PostProvider>(context,listen: false)
                                    .createPost(
                                        _imageFile,
                                        _textEditingController.text,
                                        "ghaziabad");
                                setState(() {
                                  _isUploading = false;
                                });
                                _textEditingController.text = "";
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Post",
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.lightBlueAccent),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
    );
  }
}
