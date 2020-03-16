import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';

import '../models/post.dart';
import '../models/comment.dart';
import '../models/profile.dart';
import '../models/followFollowing.dart';

class ProfileProvider with ChangeNotifier {
  final ngrokUrl = "https://astragram.herokuapp.com";

  Profile _userProfile;
  Profile _otherProfile;

  final List<Comment> _comments = [];
  final List<Post> _userPosts = [];
  final List<FollowFollowing> _followers = [];
  final List<FollowFollowing> _following = [];

  Profile get userProfile {
    return _userProfile;
  }

  Profile get otherProfile {
    return _otherProfile;
  }

  Future<void> fetchProfile(
      BuildContext context, int num, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserAuthData = json.decode(prefs.getString("userAuthData"));

    var url;

    if (num == 1) {
      url = "$ngrokUrl/user/profile/$userId";
    } else {
      url = "$ngrokUrl/user/profile/${extractedUserAuthData["userId"]}";
    }

    final response = await http.get(url,
        headers: {"Authorization": "Bearer ${extractedUserAuthData["token"]}"});
    final responseData = json.decode(response.body);

    if (responseData == null) {
      return;
    }

    if (responseData["details"]["posts"].length != 0) {
      _userPosts.clear();
      responseData["details"]["posts"].forEach((result) {
        _comments.clear();
        if (result["comments"].length != 0) {
          result["comments"].forEach((comment) {
            _comments.add(
              Comment(
                id: comment["_id"].toString(),
                username: comment["creator"]["username"],
                commentCreatorId: comment["creator"]["_id"].toString(),
                profileImageUrl:
                    comment["creator"]["profileImageUrl"].toString(),
                comment: comment["comment"],
                postedOn: comment["createdAt"],
              ),
            );
          });
        }

        final likedOrNot = result["likes"].firstWhere(
            (post) => post["_id"] == extractedUserAuthData["userId"],
            orElse: () => false);

        _userPosts.add(
          Post(
            id: result["_id"].toString(),
            username: result["creator"]["username"],
            imageUrl: result["imageUrl"].toString().substring(7),
            postCreatorId: result["creator"]["_id"].toString(),
            profileImageUrl:
                responseData["details"]["profileImageUrl"].toString(),
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
    }

    _followers.clear();
    if (responseData["details"]["followers"].length != 0) {
      responseData["details"]["followers"].forEach((user) {
        _followers.add(
          FollowFollowing(
            id: user["_id"].toString(),
            username: user["name"],
            name: user["username"],
          ),
        );
      });
    }

    _following.clear();
    if (responseData["details"]["following"].length != 0) {
      responseData["details"]["following"].forEach((user) {
        _following.add(
          FollowFollowing(
            id: user["_id"].toString(),
            username: user["name"],
            name: user["username"],
          ),
        );
      });
    }

    if (num == 0) {
      _userProfile = Profile(
        id: responseData["details"]["_id"].toString(),
        username: responseData["details"]["username"],
        name: responseData["details"]["name"],
        email: responseData["details"]["email"],
        bio: responseData["details"]["bio"] == null
            ? ""
            : responseData["details"]["bio"],
        profileImageUrl: responseData["details"]["profileImageUrl"],
        followers: List.from(_followers),
        following: List.from(_following),
        followerCount: _followers.length,
        followingCount: _following.length,
        postCount: _userPosts.length,
        posts: List.from(_userPosts),
      );
    } else {
      final beingFollowed = _followers.firstWhere(
          (follower) => follower.id == userProfile.id,
          orElse: () => null);

      _otherProfile = Profile(
        id: responseData["details"]["_id"].toString(),
        username: responseData["details"]["username"],
        name: responseData["details"]["name"],
        email: responseData["details"]["email"],
        bio: responseData["details"]["bio"] == null
            ? ""
            : responseData["details"]["bio"],
        profileImageUrl: responseData["details"]["profileImageUrl"].toString(),
        followers: List.from(_followers),
        following: List.from(_following),
        followerCount: _followers.length,
        followingCount: _following.length,
        postCount: _userPosts.length,
        posts: List.from(_userPosts),
        isBeingFollowed: beingFollowed == null ? false : true,
      );
    }
  }

  Future<void> addComment(String id, String comment, int num) async {
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
      profileImageUrl: _userProfile.profileImageUrl,
      comment: responseData["comment"]["comment"],
      postedOn: responseData["comment"]["createdAt"],
    );

    print("commented");

    if (num == 0) {
      final commentedPost =
          _userProfile.posts.firstWhere((post) => post.id == id);
      commentedPost.comments.add(commentData);
    } else {
      final commentedPost =
          _otherProfile.posts.firstWhere((post) => post.id == id);
      commentedPost.comments.add(commentData);
    }

    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(int index, int num) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserAuthData = json.decode(prefs.getString("userAuthData"));

    var url;
    if (num == 0) {
      url = "$ngrokUrl/feed/like/${_userProfile.posts[index].id}";
    } else {
      url = "$ngrokUrl/feed/like/${_otherProfile.posts[index].id}";
    }

    var currentLikedStatus;
    if (num == 0) {
      currentLikedStatus = _userProfile.posts[index].isLiked;
    } else {
      currentLikedStatus = _otherProfile.posts[index].isLiked;
    }

    final newLikedStatus = !currentLikedStatus;

    if (num == 0) {
      if (newLikedStatus) {
        final Post updatedPost = Post(
            id: _userProfile.posts[index].id,
            username: _userProfile.posts[index].username,
            imageUrl: _userProfile.posts[index].imageUrl,
            profileImageUrl: _userProfile.profileImageUrl,
            caption: _userProfile.posts[index].caption,
            location: _userProfile.posts[index].location,
            posted_on: _userProfile.posts[index].posted_on,
            no_of_likes: _userProfile.posts[index].no_of_likes + 1,
            no_of_comments: _userProfile.posts[index].no_of_comments,
            comments: _userProfile.posts[index].comments,
            isLiked: newLikedStatus);

        _userProfile.posts[index] = updatedPost;
        notifyListeners();

        final response = await http.put(url, body: {
          "num": "1"
        }, headers: {
          "Authorization": "Bearer ${extractedUserAuthData["token"]}"
        });
        final responseData = json.decode(response.body);
        print(responseData);
      } else {
        final Post updatedPost = Post(
            id: _userProfile.posts[index].id,
            username: _userProfile.posts[index].username,
            imageUrl: _userProfile.posts[index].imageUrl,
            profileImageUrl: _userProfile.profileImageUrl,
            caption: _userProfile.posts[index].caption,
            location: _userProfile.posts[index].location,
            posted_on: _userProfile.posts[index].posted_on,
            no_of_likes: _userProfile.posts[index].no_of_likes - 1,
            no_of_comments: _userProfile.posts[index].no_of_comments,
            comments: _userProfile.posts[index].comments,
            isLiked: newLikedStatus);

        _userProfile.posts[index] = updatedPost;
        notifyListeners();

        final response = await http.put(url, body: {
          "num": "0"
        }, headers: {
          "Authorization": "Bearer ${extractedUserAuthData["token"]}"
        });
        final responseData = json.decode(response.body);
        print(responseData);
      }
    } else {
      if (newLikedStatus) {
        final Post updatedPost = Post(
            id: _otherProfile.posts[index].id,
            username: _otherProfile.posts[index].username,
            imageUrl: _otherProfile.posts[index].imageUrl,
            profileImageUrl: _otherProfile.profileImageUrl,
            caption: _otherProfile.posts[index].caption,
            location: _otherProfile.posts[index].location,
            posted_on: _otherProfile.posts[index].posted_on,
            no_of_likes: _otherProfile.posts[index].no_of_likes + 1,
            no_of_comments: _otherProfile.posts[index].no_of_comments,
            comments: _otherProfile.posts[index].comments,
            isLiked: newLikedStatus);

        _otherProfile.posts[index] = updatedPost;
        notifyListeners();

        final response = await http.put(url, body: {
          "num": "1"
        }, headers: {
          "Authorization": "Bearer ${extractedUserAuthData["token"]}"
        });
        final responseData = json.decode(response.body);
        print(responseData);
      } else {
        final Post updatedPost = Post(
            id: _otherProfile.posts[index].id,
            username: _otherProfile.posts[index].username,
            imageUrl: _otherProfile.posts[index].imageUrl,
            caption: _otherProfile.posts[index].caption,
            profileImageUrl: _otherProfile.profileImageUrl,
            location: _otherProfile.posts[index].location,
            posted_on: _otherProfile.posts[index].posted_on,
            no_of_likes: _otherProfile.posts[index].no_of_likes - 1,
            no_of_comments: _otherProfile.posts[index].no_of_comments,
            comments: _otherProfile.posts[index].comments,
            isLiked: newLikedStatus);

        _otherProfile.posts[index] = updatedPost;
        notifyListeners();

        final response = await http.put(url, body: {
          "num": "0"
        }, headers: {
          "Authorization": "Bearer ${extractedUserAuthData["token"]}"
        });
        final responseData = json.decode(response.body);
        print(responseData);
      }
    }
  }

  Future<void> toggleFollowFollowing(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserAuthData = json.decode(prefs.getString("userAuthData"));

    final currentLikedStatus = _otherProfile.isBeingFollowed;
    final newFollowStatus = !currentLikedStatus;

    final url = "$ngrokUrl/user/follow/$id";

    if (newFollowStatus) {
      _userProfile.following.add(FollowFollowing(
          id: _otherProfile.id,
          username: _otherProfile.username,
          name: _otherProfile.name));
      final updatedUserProfile = Profile(
        id: _userProfile.id,
        username: _userProfile.username,
        name: _userProfile.name,
        email: _userProfile.email,
        bio: _userProfile.bio,
        profileImageUrl: _userProfile.profileImageUrl,
        followers: _userProfile.followers,
        followerCount: _userProfile.followers.length,
        following: _userProfile.following,
        followingCount: _userProfile.following.length,
        postCount: _userProfile.posts.length,
        posts: _userProfile.posts,
      );
      _userProfile = updatedUserProfile;

      _otherProfile.followers.add(FollowFollowing(
          id: _userProfile.id,
          username: _userProfile.username,
          name: _userProfile.name));
      final updatedOtherProfile = Profile(
          id: _otherProfile.id,
          username: _otherProfile.username,
          name: _otherProfile.name,
          email: _otherProfile.email,
          bio: _otherProfile.bio,
          profileImageUrl: _otherProfile.profileImageUrl,
          followers: _otherProfile.followers,
          followerCount: _otherProfile.followers.length,
          following: _otherProfile.following,
          followingCount: _otherProfile.following.length,
          postCount: _otherProfile.posts.length,
          posts: _otherProfile.posts,
          isBeingFollowed: newFollowStatus);
      _otherProfile = updatedOtherProfile;

      notifyListeners();

      final response = await http.put(url, body: {
        "num": "1"
      }, headers: {
        "Authorization": "Bearer ${extractedUserAuthData["token"]}"
      });
      final responseData = json.decode(response.body);
      print(responseData);
    } else {
      _userProfile.following.removeWhere((user) => user.id == _otherProfile.id);
      final updatedUserProfile = Profile(
        id: _userProfile.id,
        username: _userProfile.username,
        name: _userProfile.name,
        email: _userProfile.email,
        bio: _userProfile.bio,
        profileImageUrl: _userProfile.profileImageUrl,
        followers: _userProfile.followers,
        followerCount: _userProfile.followers.length,
        following: _userProfile.following,
        followingCount: _userProfile.following.length,
        postCount: _userProfile.posts.length,
        posts: _userProfile.posts,
      );
      _userProfile = updatedUserProfile;

      _otherProfile.followers.removeWhere((user) => user.id == _userProfile.id);
      final updatedOtherProfile = Profile(
          id: _otherProfile.id,
          username: _otherProfile.username,
          name: _otherProfile.name,
          email: _otherProfile.email,
          bio: _otherProfile.bio,
          profileImageUrl: _otherProfile.profileImageUrl,
          followers: _otherProfile.followers,
          followerCount: _otherProfile.followers.length,
          following: _otherProfile.following,
          followingCount: _otherProfile.following.length,
          postCount: _otherProfile.posts.length,
          posts: _otherProfile.posts,
          isBeingFollowed: newFollowStatus);
      _otherProfile = updatedOtherProfile;

      notifyListeners();

      final response = await http.put(url, body: {
        "num": "0"
      }, headers: {
        "Authorization": "Bearer ${extractedUserAuthData["token"]}"
      });
      final responseData = json.decode(response.body);
      print(responseData);
    }
  }

  Future<void> updateProfile(
      String name, String username, String email, String bio) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserAuthData = json.decode(prefs.getString("userAuthData"));

    final url = "$ngrokUrl/user/updateProfile";

    final response = await http.put(url, body: {
      "name": name,
      "username": username,
      "email": email,
      "bio": bio,
    }, headers: {
      "Authorization": "Bearer ${extractedUserAuthData["token"]}"
    });

    final responseData = json.decode(response.body);
    print(responseData);

    final updatedProfile = Profile(
      id: _userProfile.id,
      username: username,
      name: name,
      email: email,
      bio: bio,
      profileImageUrl: _userProfile.profileImageUrl,
      followers: _userProfile.followers,
      followerCount: _userProfile.followers.length,
      following: _userProfile.following,
      followingCount: _userProfile.following.length,
      postCount: _userProfile.posts.length,
      posts: _userProfile.posts,
    );

    _userProfile = updatedProfile;
    notifyListeners();
  }

  Future<void> updateProfileImage(File image) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserAuthData = json.decode(prefs.getString("userAuthData"));

    String filename = basename(image.path);
    final mimeTypeData = lookupMimeType(image.path).split("/");

    FormData formData = FormData.fromMap(
      {
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
      final response = await Dio().put(
        "$ngrokUrl/user/updateProfileImage",
        data: formData,
        options: Options(
          responseType: ResponseType.json,
          headers: {
            "Authorization": "Bearer ${extractedUserAuthData["token"]}",
          },
        ),
      );

      final responseData = response.data;

      print(responseData);

      final updatedProfile = Profile(
        id: _userProfile.id,
        username: _userProfile.username,
        name: _userProfile.name,
        email: _userProfile.email,
        bio: _userProfile.bio,
        profileImageUrl: responseData["profileImageUrl"],
        followers: _userProfile.followers,
        followerCount: _userProfile.followers.length,
        following: _userProfile.following,
        followingCount: _userProfile.following.length,
        postCount: _userProfile.posts.length,
        posts: _userProfile.posts,
      );

      _userProfile = updatedProfile;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

}
