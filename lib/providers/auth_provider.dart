import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//import '../pages/authentication/otp_page.dart';
//import 'home_page.dart';
import '../pages/authentication/auth_page.dart';
//import '../pages/main_page.dart';


class AuthProvider extends ChangeNotifier {

  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  String _username;

  final ngrokUrl = "https://astragram.herokuapp.com";

  bool get isAuthenticated {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("An error Occured!"),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Okay"),
          ),
        ],
      ),
    );
  }

  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      final response = await http.post(
          "$ngrokUrl/user/login",
          body: json.encode(
            {
              "email": email,
              "password": password,
            },
          ),
          headers: {"Content-type": "application/json"}
      );

      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData["error"] != null) {
        _showErrorDialog(context, responseData["error"]);
        return;
      }

      _token = responseData["token"];
      _userId = responseData["userId"];
      _username = responseData["username"];
      _expiryDate = DateTime.now().add(Duration(hours: 12),);

      autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userAuthData = json.encode(
        {
          "token": _token,
          "userId": _userId,
          "username": _username,
          "expiryDate": _expiryDate.toIso8601String(),
        },
      );
      prefs.setString("userAuthData", userAuthData);
    } catch(error){
      _showErrorDialog(context, error.toString());
    }

  }

  Future<void> signUp(
      BuildContext context, String name,String username ,String email, String password) async {

    final response = await http.put("$ngrokUrl/user/signup",
        body: json.encode(
          {
            "name": name,
            "username": username,
            "email": email,
            "password": password,
          },
        ),
        headers: {"Content-type": "application/json"});

    final responseData = json.decode(response.body);
    print(responseData);
    if (responseData["error"] != null) {
      _showErrorDialog(context, responseData["error"]);
      return;
    }

    await login(context, email, password);
  }

  Future<void> logout() async {
    _expiryDate = null;
    _userId = null;
    _token = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();

  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("userAuthData")) {
      return false;
    }

    final extractedUserAuthData =
    json.decode(prefs.getString("userAuthData")) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserAuthData["expiryDate"]);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _username = extractedUserAuthData["username"];
    _token = extractedUserAuthData["token"];
    _expiryDate = expiryDate;

    notifyListeners();
    autoLogout();

    return true;
  }

  void autoLogout(){
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final expiryTime = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: expiryTime), logout);
  }

}