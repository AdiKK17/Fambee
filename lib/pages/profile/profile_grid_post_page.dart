import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../providers/profile_provider.dart';
import '../home/comments_page.dart';
import 'others_profile_page.dart';

class PostPage extends StatefulWidget {
  final int index;
  final int num;

  PostPage(this.index, this.num);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PostPage();
  }
}

class _PostPage extends State<PostPage> {
  bool _showHeartOverlay = false;
  bool _isCommenting = false;

  Widget _buildUpperPostComponent(int index) {
    return ListTile(
      title: GestureDetector(
//        onTap: () => Navigator.of(context).push(
//          MaterialPageRoute(
//            builder: (context) => OtherProfilePage(widget.num == 0
//                ? Provider.of<ProfileProvider>(context)
//                    .userProfile
//                    .posts[index]
//                    .postCreatorId
//                : Provider.of<ProfileProvider>(context)
//                    .otherProfile
//                    .posts[index]
//                    .postCreatorId),
//          ),
//        ),
        child: Text(
          widget.num == 0
              ? Provider.of<ProfileProvider>(context).userProfile.username
              : Provider.of<ProfileProvider>(context).otherProfile.username,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      subtitle: widget.num == 0
          ? Text(Provider.of<ProfileProvider>(context)
              .userProfile
              .posts[index]
              .location)
          : Text(Provider.of<ProfileProvider>(context)
              .otherProfile
              .posts[index]
              .location),
    );
  }

  Widget _buildPostImage(int index) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(60),
              bottomRight: Radius.circular(60),
            ),
            child: CachedNetworkImage(
              imageUrl: widget.num == 0
                  ? "${Provider.of<ProfileProvider>(context).ngrokUrl}/images/${Provider.of<ProfileProvider>(context).userProfile.posts[index].imageUrl}"
                  : "${Provider.of<ProfileProvider>(context).ngrokUrl}/images/${Provider.of<ProfileProvider>(context).otherProfile.posts[index].imageUrl}",
              placeholder: (context, url) {
                return Image.asset(
                  "assets/loadingImage.gif",
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.contain,
                );
              },
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
        ),
        _showHeartOverlay
            ? Icon(
                Icons.favorite,
                size: 80,
                color: Colors.white,
              )
            : Container()
      ],
    );
  }

  Widget _buildLikeCommentRow(int index) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: widget.num == 0
              ? Icon(Provider.of<ProfileProvider>(context)
                      .userProfile
                      .posts[index]
                      .isLiked
                  ? Icons.favorite
                  : Icons.favorite_border)
              : Icon(Provider.of<ProfileProvider>(context)
                      .otherProfile
                      .posts[index]
                      .isLiked
                  ? Icons.favorite
                  : Icons.favorite_border),
          iconSize: 30,
          onPressed: () {
            Provider.of<ProfileProvider>(context, listen: false)
                .toggleFavoriteStatus(index, widget.num);
          },
        ),
        SizedBox(
          width: 4,
        ),
        Text(
          widget.num == 0
              ? Provider.of<ProfileProvider>(context, listen: false)
                  .userProfile
                  .posts[index]
                  .no_of_likes
                  .toString()
              : Provider.of<ProfileProvider>(context, listen: false)
                  .otherProfile
                  .posts[index]
                  .no_of_likes
                  .toString(),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(
            Icons.comment,
          ),
          iconSize: 30,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => widget.num == 0
                    ? CommentsPage(
                        Provider.of<ProfileProvider>(context)
                            .userProfile
                            .posts[index]
                            .username,
                        Provider.of<ProfileProvider>(context)
                            .userProfile
                            .posts[index]
                            .id,
                        "  ${Provider.of<ProfileProvider>(context).userProfile.posts[index].caption}",
                        Provider.of<ProfileProvider>(context)
                            .userProfile
                            .posts[index]
                            .comments,
                      )
                    : CommentsPage(
                        Provider.of<ProfileProvider>(context)
                            .otherProfile
                            .posts[index]
                            .username,
                        Provider.of<ProfileProvider>(context)
                            .otherProfile
                            .posts[index]
                            .id,
                        "  ${Provider.of<ProfileProvider>(context).otherProfile.posts[index].caption}",
                        Provider.of<ProfileProvider>(context)
                            .otherProfile
                            .posts[index]
                            .comments,
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCaption(BuildContext context, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: RichText(
        text: TextSpan(
//          style: DefaultTextStyle.of(context).style,
          style: TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: widget.num == 0
                  ? Provider.of<ProfileProvider>(context).userProfile.username
                  : Provider.of<ProfileProvider>(context).otherProfile.username,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
                text: widget.num == 0
                    ? "  ${Provider.of<ProfileProvider>(context).userProfile.posts[index].caption}"
                    : "  ${Provider.of<ProfileProvider>(context).otherProfile.posts[index].caption}")
          ],
        ),
      ),
    );
  }

  Widget _buildCommentTextField(int index) {
    TextEditingController _textEditingController = TextEditingController();

    return ListTile(
      title: TextFormField(
        textInputAction: TextInputAction.send,
        controller: _textEditingController,
        decoration: InputDecoration.collapsed(hintText: "Add a comment..."),
      ),
      trailing: FlatButton(
        padding: EdgeInsets.all(0),
        onPressed: () async {
          setState(() {
            _isCommenting = true;
          });
          if (_textEditingController.text.isEmpty) {
            return;
          }

          final comment = _textEditingController.text;
          _textEditingController.text = "";

          if (widget.num == 0) {
            await Provider.of<ProfileProvider>(context, listen: false)
                .addComment(
                    Provider.of<ProfileProvider>(context, listen: false)
                        .userProfile
                        .posts[index]
                        .id,
                    comment,
                    widget.num);
          } else {
            await Provider.of<ProfileProvider>(context, listen: false)
                .addComment(
                    Provider.of<ProfileProvider>(context, listen: false)
                        .otherProfile
                        .posts[index]
                        .id,
                    comment,
                    widget.num);
          }

          Fluttertoast.showToast(
              msg: "Comment Added",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0);

          _isCommenting = false;
          setState(() {});
        },
        child: _isCommenting ? Text("") : Text("Post"),
      ),
    );
  }

  //needs to be cheched
  void _showBigHeart(int index) {
    setState(() {
      _showHeartOverlay = true;
      Provider.of<ProfileProvider>(context, listen: false)
          .toggleFavoriteStatus(index, widget.num);
      if (_showHeartOverlay) {
        Timer(Duration(milliseconds: 500), () {
          setState(() {
            _showHeartOverlay = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ProfileProvider>(context);

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Post"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildUpperPostComponent(widget.index),
            AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                  onDoubleTap: () {
                    _showBigHeart(widget.index);
                  },
                  child: _buildPostImage(widget.index)),
            ),
            _buildLikeCommentRow(widget.index),
            _buildCaption(context, widget.index),
            FlatButton(
              padding: EdgeInsets.symmetric(horizontal: 10),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => widget.num == 0
                        ? CommentsPage(
                            model.userProfile.username,
                            model.userProfile.id,
                            model.userProfile.posts[widget.index].caption,
                            model.userProfile.posts[widget.index].comments)
                        : CommentsPage(
                            model.otherProfile.username,
                            model.otherProfile.id,
                            model.otherProfile.posts[widget.index].caption,
                            model.otherProfile.posts[widget.index].comments),
                  ),
                );
              },
              child: widget.num == 0
                  ? Text(model.userProfile.posts[widget.index].comments
                              .length ==
                          0
                      ? "No comments"
                      : "View all ${model.userProfile.posts[widget.index].comments.length} comments")
                  : Text(model.otherProfile.posts[widget.index].comments
                              .length ==
                          0
                      ? "No comments"
                      : "View all ${model.otherProfile.posts[widget.index].comments.length} comments"),
            ),
            _isCommenting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _buildCommentTextField(widget.index),
          ],
        ),
      ),
    );
  }
}
