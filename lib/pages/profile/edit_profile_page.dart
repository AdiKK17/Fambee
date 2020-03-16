import 'dart:io';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/profile_provider.dart';
import 'profile_image_page.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EditProfilePage();
  }
}

class _EditProfilePage extends State<EditProfilePage> {
  var _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> _formData = {
    "name": null,
    "username": null,
    "email": null,
    "bio": null,
//    "profile_image": null,
  };

  File _imageFile;

  Future<void> _getImage(BuildContext context, ImageSource source) async {
    final _image = await ImagePicker.pickImage(source: source, maxWidth: 800);
    setState(() {
      _imageFile = _image;
    });
    print(_imageFile);

    if(_imageFile != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfileImagePreview(_imageFile)));
    }

  }

  Widget _buildProfileImage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Change Display picture"),
                content: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 3,
                        ),
                        FlatButton(
                          onPressed: () {
                            _getImage(context, ImageSource.camera);
                          },
                          child: Text("Camera"),
                        ),
                        Divider(),
                        FlatButton(
                          onPressed: () {
                            _getImage(context, ImageSource.gallery);
                          },
                          child: Text("Gallery"),
                        )
                      ],
                    ),
                  ),
                ),
              );
            });
      },
      child:
          Provider.of<ProfileProvider>(context).userProfile.profileImageUrl ==
                  null
              ? CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/default.jpg"),
                )
              : CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      "${Provider.of<ProfileProvider>(context).ngrokUrl}/images/${Provider.of<ProfileProvider>(context).userProfile.profileImageUrl.substring(7)}"),
                ),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      initialValue: Provider.of<ProfileProvider>(context).userProfile.email,
      decoration: InputDecoration(
        labelText: 'E-Mail',
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black54),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildUsernameTextField() {
    return TextFormField(
      initialValue: Provider.of<ProfileProvider>(context).userProfile.username,
      decoration: InputDecoration(
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        labelText: 'UserName',
      ),
      keyboardType: TextInputType.text,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['username'] = value;
      },
    );
  }

  Widget _buildNameTextField() {
    return TextFormField(
      initialValue: Provider.of<ProfileProvider>(context).userProfile.name,
      decoration: InputDecoration(
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          labelText: 'Full Name'),
      keyboardType: TextInputType.text,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['name'] = value;
      },
    );
  }

  Widget _buildBioTextField() {
    return TextFormField(
      initialValue: Provider.of<ProfileProvider>(context).userProfile.bio,
      decoration: InputDecoration(
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          labelText: 'Bio'),
      keyboardType: TextInputType.text,
      validator: (String value) {
//        if (value.isEmpty) {
//          return 'Please enter a valid email';
//        }
        return null;
      },
      onSaved: (String value) {
        _formData['bio'] = value;
      },
    );
  }

  Widget _buildRaisedButton() {
    return RaisedButton(
      onPressed: () {
        _submitForm();
      },
      child: Text("Update"),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    setState(() {
      _isLoading = true;
    });

    await Provider.of<ProfileProvider>(context, listen: false).updateProfile(
        _formData["name"],
        _formData["username"],
        _formData["email"],
        _formData["bio"]);

    setState(() {
      _isLoading = false;
    });

    Fluttertoast.showToast(
        msg: "Details Updated",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.black,
        fontSize: 16.0);

    print("its done");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit"),
      ),
      body: _isLoading
          ? Center(
              child: Text(
                "Updating...",
                style: TextStyle(fontSize: 30, color: Colors.grey),
              ),
            )
          : Container(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      _buildProfileImage(context),
                      SizedBox(
                        height: 30,
                      ),
                      _buildEmailTextField(),
                      SizedBox(
                        height: 20,
                      ),
                      _buildUsernameTextField(),
                      SizedBox(
                        height: 20,
                      ),
                      _buildNameTextField(),
                      SizedBox(
                        height: 20,
                      ),
                      _buildBioTextField(),
                      SizedBox(
                        height: 35,
                      ),
                      _buildRaisedButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
