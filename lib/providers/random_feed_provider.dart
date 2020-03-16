import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../models/comment.dart';
import 'profile_provider.dart';

class RandomFeedProvider extends ChangeNotifier{

  var i = 2;
  bool noMorePosts = false;
  final ngrokUrl = "https://astragram.herokuapp.com";

  final List<Post> _randomFeed = [];
  final List<Comment> _comments = [];

  List<Post> get randomFeed {
    return List.from(_randomFeed);
  }


  Future<void> fetchRandomFeed() async {

    i = 2;
    noMorePosts = false;

    final prefs = await SharedPreferences.getInstance();
    final extractedUserAuthData = json.decode(prefs.getString("userAuthData"));

    final url = "$ngrokUrl/feed/posts?page=1";
    final response = await http.get(url,
        headers: {"Authorization": "Bearer ${extractedUserAuthData["token"]}"});

    final responseData = json.decode(response.body);

    if (responseData["currentPosts"] == 0) {
      return;
    }

    _randomFeed.clear();
    responseData["posts"].forEach((result) {
      _comments.clear();
      if (result["comments"].length != 0) {
        result["comments"].forEach((comment) {
          _comments.add(
            Comment(
              id: comment["_id"].toString(),
              username: comment["creator"]["username"],
              commentCreatorId: comment["creator"]["_id"].toString(),
              profileImageUrl: comment["creator"]["profileImageUrl"].toString(),
              comment: comment["comment"],
              postedOn: comment["createdAt"],
            ),
          );
        });
      }

      final likedOrNot = result["likes"].firstWhere((post) => post["_id"] == extractedUserAuthData["userId"],orElse: () => false );

      _randomFeed.add(
        Post(
          id: result["_id"].toString(),
          username: result["creator"]["username"],
          postCreatorId: result["creator"]["_id"].toString(),
          imageUrl: result["imageUrl"].toString().substring(7),
          profileImageUrl: result["creator"]["profileImageUrl"].toString(),
          caption: result["caption"],
          location: result["location"],
          posted_on: result["createdAt"],
          no_of_comments: _comments.length,
          comments: List.from(_comments),
          no_of_likes: result["likes"].length,
          isLiked: likedOrNot == false ? false : true,
        ),
      );
    });
    notifyListeners();
  }

  Future<void> addToRandomFeed() async {
    if (!noMorePosts) {
      final prefs = await SharedPreferences.getInstance();
      final extractedUserAuthData =
      json.decode(prefs.getString("userAuthData"));

      final url = "$ngrokUrl/feed/posts?page=${i++}";
      final response = await http.get(url, headers: {
        "Authorization": "Bearer ${extractedUserAuthData["token"]}"
      });

      final responseData = json.decode(response.body);

      if (responseData["currentPosts"] < 15) {
        noMorePosts = true;
      } else {
        noMorePosts = false;
      }

      if (responseData["currentPosts"] == 0) {
        return;
      }

      responseData["posts"].forEach((result) {
        _comments.clear();
        if (result["comments"].length != 0) {
          result["comments"].forEach((comment) {
            _comments.add(
              Comment(
                id: comment["_id"].toString(),
                username: comment["creator"]["username"],
                commentCreatorId: comment["creator"]["_id"].toString(),
                profileImageUrl: comment["creator"]["profileImageUrl"].toString(),
                comment: comment["comment"],
                postedOn: comment["createdAt"],
              ),
            );
          });
        }

        final likedOrNot = result["likes"].firstWhere((post) => post.id == extractedUserAuthData["userId"],orElse: () => false );

        _randomFeed.add(
          Post(
            id: result["_id"].toString(),
            username: result["creator"]["username"],
            imageUrl: result["imageUrl"].toString().substring(7),
            profileImageUrl: result["creator"]["profileImageUrl"].toString(),
            caption: result["caption"],
            location: result["location"],
            posted_on: result["createdAt"],
            no_of_comments: _comments.length,
            comments: List.from(_comments),
            no_of_likes: result["no_of_likes"],
            isLiked: likedOrNot == false ? false : true,
          ),
        );
      });
      notifyListeners();
    }
  }

  Future<void> addComment(BuildContext context, String id, String comment) async {

    final prefs = await SharedPreferences.getInstance();
    final extractedUserAuthData = json.decode(prefs.getString("userAuthData"));

    final url = "$ngrokUrl/feed/comment/$id";

    final response = await http.post(url,
        body: {"comment": comment},
        headers: {"Authorization": "Bearer ${extractedUserAuthData["token"]}"});
    final responseData = json.decode(response.body);

    final commentData = Comment(
      id: responseData["comment"]["_id"].toString(),
      username: extractedUserAuthData["username"],
      commentCreatorId: extractedUserAuthData["userId"],
      profileImageUrl: Provider.of<ProfileProvider>(context).userProfile.profileImageUrl,
      comment: responseData["comment"]["comment"],
      postedOn: responseData["comment"]["createdAt"],
    );


    print("commented");

    final commentedPost = _randomFeed.firstWhere((post) => post.id == id);
    print(commentedPost.id);
    commentedPost.comments.add(commentData);

    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(int index) async {

    final prefs = await SharedPreferences.getInstance();
    final extractedUserAuthData = json.decode(prefs.getString("userAuthData"));

    final url = "$ngrokUrl/feed/like/${_randomFeed[index].id}";

    final currentLikedStatus = _randomFeed[index].isLiked;
    final newLikedStatus = !currentLikedStatus;

    if (newLikedStatus) {
      final Post updatedPost = Post(
          id: _randomFeed[index].id,
          username: _randomFeed[index].username,
          imageUrl: _randomFeed[index].imageUrl,
          caption: _randomFeed[index].caption,
          location: _randomFeed[index].location,
          posted_on: _randomFeed[index].posted_on,
          no_of_likes: _randomFeed[index].no_of_likes + 1,
          no_of_comments: _randomFeed[index].no_of_comments,
          comments: _randomFeed[index].comments,
          isLiked: newLikedStatus);

      _randomFeed[index] = updatedPost;
      notifyListeners();


      final response = await http.put(url,
          body: {"num": "1"},
          headers: {"Authorization": "Bearer ${extractedUserAuthData["token"]}"});
      final responseData = json.decode(response.body);
      print(responseData);

    } else {
      final Post updatedPost = Post(
          id: _randomFeed[index].id,
          username: _randomFeed[index].username,
          imageUrl: _randomFeed[index].imageUrl,
          caption: _randomFeed[index].caption,
          location: _randomFeed[index].location,
          posted_on: _randomFeed[index].posted_on,
          no_of_likes: _randomFeed[index].no_of_likes - 1,
          no_of_comments: _randomFeed[index].no_of_comments,
          comments: _randomFeed[index].comments,
          isLiked: newLikedStatus);

      _randomFeed[index] = updatedPost;
      notifyListeners();

      final response = await http.put(url,
          body: {"num": "0"},
          headers: {"Authorization": "Bearer ${extractedUserAuthData["token"]}"});
      final responseData = json.decode(response.body);
      print(responseData);
    }
  }

}