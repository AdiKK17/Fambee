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

class PostProvider with ChangeNotifier {
  var i = 2;
  bool noMorePosts = false;
  final ngrokUrl = "https://astragram.herokuapp.com";

  final List<Post> _homeFeed = [];
  final List<Comment> _comments = [];

  List<Post> get homeFeed {
    return List.from(_homeFeed);
  }

  Future<void> createPost(File image, String caption, String location) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserAuthData = json.decode(prefs.getString("userAuthData"));

    String filename = basename(image.path);
    final mimeTypeData = lookupMimeType(image.path).split("/");

    FormData formData = FormData.fromMap(
      {
        "caption": caption,
        "location": location,
        "image": await MultipartFile.fromFile(
          image.path,
          filename: filename,
          contentType: MediaType(
            mimeTypeData[0],
            mimeTypeData[1],
          ),
        ),
      },
    );

    try {
      final response = await Dio().post(
        "$ngrokUrl/feed/post",
        data: formData,
        options: Options(
          responseType: ResponseType.json,
          headers: {
            "Authorization": "Bearer ${extractedUserAuthData["token"]}",
          },
        ),
      );

      final responseData = response.data;

      _homeFeed.add(
        Post(
          id: responseData["_id"].toString(),
          imageUrl: responseData["imageUrl"].toString().substring(7),
          caption: responseData["caption"],
          location: responseData["location"],
          posted_on: responseData["createdAt"],
          comments: responseData["comments"],
          no_of_comments: 0,
          no_of_likes: 0,
        ),
      );

      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> fetchHomeFeed() async {

    i = 2;
    noMorePosts = false;

    final prefs = await SharedPreferences.getInstance();
    final extractedUserAuthData = json.decode(prefs.getString("userAuthData"));

    final url = "$ngrokUrl/feed/homePosts?page=1";
    final response = await http.get(url,
        headers: {"Authorization": "Bearer ${extractedUserAuthData["token"]}"});

    final responseData = json.decode(response.body);

    if (responseData["currentPosts"] == 0) {
      return;
    }

    _homeFeed.clear();
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


      _homeFeed.add(
        Post(
          id: result["_id"].toString(),
          username: result["creator"]["username"],
          postCreatorId: result["creator"]["_id"].toString(),
          profileImageUrl: result["creator"]["profileImageUrl"].toString(),
          imageUrl: result["imageUrl"].toString().substring(7),
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

  Future<void> addToHomeFeed() async {
    if (!noMorePosts) {
      final prefs = await SharedPreferences.getInstance();
      final extractedUserAuthData =
          json.decode(prefs.getString("userAuthData"));

      final url = "$ngrokUrl/feed/homePosts?page=${i++}";
      final response = await http.get(url, headers: {
        "Authorization": "Bearer ${extractedUserAuthData["token"]}"
      });

      final responseData = json.decode(response.body);

      if (responseData["currentPosts"] < 3) {
        noMorePosts = true;
      } else {
        noMorePosts = false;
      }

//      print(noMorePosts);

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

        final likedOrNot = result["likes"].firstWhere((post) => post["_id"] == extractedUserAuthData["userId"],orElse: () => false );

        _homeFeed.add(
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
            no_of_likes: result["likes"].length,
            isLiked: likedOrNot == false ? false : true,
          ),
        );
      });
      notifyListeners();
    }
  }

  Future<void> addComment(BuildContext context,String id, String comment) async {

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

    final commentedPost = _homeFeed.firstWhere((post) => post.id == id);
    print(commentedPost.id);
    commentedPost.comments.add(commentData);

    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(int index) async {

    final prefs = await SharedPreferences.getInstance();
    final extractedUserAuthData = json.decode(prefs.getString("userAuthData"));

    final url = "$ngrokUrl/feed/like/${_homeFeed[index].id}";

    final currentLikedStatus = _homeFeed[index].isLiked;
    final newLikedStatus = !currentLikedStatus;

    if (newLikedStatus) {
      final Post updatedPost = Post(
          id: _homeFeed[index].id,
          username: _homeFeed[index].username,
          imageUrl: _homeFeed[index].imageUrl,
          profileImageUrl: _homeFeed[index].profileImageUrl,
          caption: _homeFeed[index].caption,
          location: _homeFeed[index].location,
          posted_on: _homeFeed[index].posted_on,
          no_of_likes: _homeFeed[index].no_of_likes + 1,
          no_of_comments: _homeFeed[index].no_of_comments,
          comments: _homeFeed[index].comments,
          isLiked: newLikedStatus);

      _homeFeed[index] = updatedPost;
      notifyListeners();


      final response = await http.put(url,
          body: {"num": "1"},
          headers: {"Authorization": "Bearer ${extractedUserAuthData["token"]}"});
      final responseData = json.decode(response.body);
      print(responseData);

    } else {
      final Post updatedPost = Post(
          id: _homeFeed[index].id,
          username: _homeFeed[index].username,
          imageUrl: _homeFeed[index].imageUrl,
          profileImageUrl: _homeFeed[index].profileImageUrl,
          caption: _homeFeed[index].caption,
          location: _homeFeed[index].location,
          posted_on: _homeFeed[index].posted_on,
          no_of_likes: _homeFeed[index].no_of_likes - 1,
          no_of_comments: _homeFeed[index].no_of_comments,
          comments: _homeFeed[index].comments,
          isLiked: newLikedStatus);

      _homeFeed[index] = updatedPost;
      notifyListeners();

      final response = await http.put(url,
          body: {"num": "0"},
          headers: {"Authorization": "Bearer ${extractedUserAuthData["token"]}"});
      final responseData = json.decode(response.body);
      print(responseData);
    }
  }

}
