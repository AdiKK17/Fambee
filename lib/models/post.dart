import 'package:flutter/material.dart';

import 'comment.dart';

class Post{
  final String id;
  final String username;
  final String postCreatorId;
  final String profileImageUrl;
  final String imageUrl;
  final String caption;
  final String location;
  final String posted_on;
  final int no_of_likes;
  final int no_of_comments;
  final List<Comment> comments;
  bool isLiked;

  Post({@required this.id,this.username,this.postCreatorId,this.profileImageUrl,@required this.imageUrl,@required this.caption,@required this.location,@required this.posted_on,@required this.no_of_comments,@required this.no_of_likes,@required this.comments, this.isLiked = false});

}