import 'package:flutter/material.dart';

import 'post.dart';
import 'followFollowing.dart';

class Profile{
  final String id;
  final String username;
  final String name;
  final String email;
  final String bio;
  final String profileImageUrl;
  final List<FollowFollowing> followers;
  final int followerCount;
  final List<FollowFollowing> following;
  final int followingCount;
  final int postCount;
  final List<Post> posts;
  bool isBeingFollowed;
  Profile({@required this.id,@required this.username,@required this.name,this.email,@required this.profileImageUrl,this.bio,@required this.followers,@required this.followerCount,@required this.following,@required this.followingCount,@required this.postCount,@required this.posts,this.isBeingFollowed = false});
}