import 'package:flutter/material.dart';

class Comment{
  final String id;
  final String commentCreatorId;
  final String username;
  final String profileImageUrl;
  final String comment;
  final String postedOn;

  Comment({@required this.id,@required this.username,@required this.commentCreatorId,@required this.profileImageUrl,@required this.comment,@required this.postedOn});
}