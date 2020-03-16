import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/searchList.dart';

class SearchProvider extends ChangeNotifier {

  final ngrokUrl = "https://astragram.herokuapp.com";

  final List<SearchList> _userList = [];

  List<SearchList> get userList {
    return List.from(_userList);
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

  Future<void> fetchSearchResults(BuildContext context, String query) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserAuthData = json.decode(prefs.getString("userAuthData"));

    _userList.clear();

    final url = "$ngrokUrl/user/search?q=$query";

    try {
      final response = await http.get(url, headers: {
        "Authorization": "Bearer ${extractedUserAuthData["token"]}"
      });
      final responseData = json.decode(response.body);

      if (responseData["result"].length == 0) {
        return;
      }

      responseData["result"].forEach((user) {
        _userList.add(
          SearchList(
            id: user["_id"],
            name: user["name"],
            username: user["username"],
            profileImageUrl: user["profileImageUrl"].toString()
          ),
        );
      });
      notifyListeners();
    } catch (error) {
      print(error);
      var errorMessage = "Could not fetch Data! Try again later";
//      print(errorMessage);
      _showErrorDialog(context,errorMessage);
    }
  }
}
