import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../providers/random_feed_provider.dart';
import '../home/comments_page.dart';
import '../profile/others_profile_page.dart';

class RandomPostPage extends StatefulWidget {
  final int index;
  final int num;

  RandomPostPage(this.index,this.num);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RandomPostPage();
  }
}

class _RandomPostPage extends State<RandomPostPage> {

  bool _showHeartOverlay = false;
  bool _isCommenting = false;

  Widget _buildUpperPostComponent(int index) {
    return ListTile(
      title: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtherProfilePage(
                Provider.of<RandomFeedProvider>(context).randomFeed[index].postCreatorId),
          ),
        ),
        child: Text(
          Provider.of<RandomFeedProvider>(context).randomFeed[index].username,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      subtitle: Text(Provider.of<RandomFeedProvider>(context).randomFeed[index].location),
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
              imageUrl: "${Provider.of<RandomFeedProvider>(context).ngrokUrl}/images/${Provider.of<RandomFeedProvider>(context).randomFeed[index].imageUrl}" ,
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
          icon: Icon(Provider.of<RandomFeedProvider>(context)
              .randomFeed[index]
              .isLiked
              ? Icons.favorite
              : Icons.favorite_border),
          iconSize: 30,
          onPressed: () {
            Provider.of<RandomFeedProvider>(context, listen: false)
                .toggleFavoriteStatus(index);
          },
        ),
        SizedBox(
          width: 4,
        ),
        Text(
         Provider.of<RandomFeedProvider>(context, listen: false)
              .randomFeed[index]
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
                builder: (context) => CommentsPage(
                  Provider.of<RandomFeedProvider>(context)
                      .randomFeed[index]
                      .username,
                  Provider.of<RandomFeedProvider>(context)
                      .randomFeed[index]
                      .id,
                  "  ${Provider.of<RandomFeedProvider>(context).randomFeed[index].caption}",
                  Provider.of<RandomFeedProvider>(context)
                      .randomFeed[index]
                      .comments,
                )
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
              text: Provider.of<RandomFeedProvider>(context).randomFeed[index].username ,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
                text: "  ${Provider.of<RandomFeedProvider>(context).randomFeed[index].caption}")
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

          if(widget.num == 0) {
            await Provider.of<RandomFeedProvider>(context, listen: false)
                .addComment(context,
                Provider
                    .of<RandomFeedProvider>(context, listen: false)
                    .randomFeed[index]
                    .id,
                comment);
          } else {
            await Provider.of<RandomFeedProvider>(context, listen: false)
                .addComment(context,
                Provider
                    .of<RandomFeedProvider>(context, listen: false)
                    .randomFeed[index]
                    .id,
                comment);
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
      Provider.of<RandomFeedProvider>(context, listen: false)
          .toggleFavoriteStatus(index);
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

    final model = Provider.of<RandomFeedProvider>(context);

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
                    builder: (context) => CommentsPage(
                      model.randomFeed[widget.index].username,
                      model.randomFeed[widget.index].username,
                      "  ${model.randomFeed[widget.index].caption}",
                      model.randomFeed[widget.index].comments,)
                  ),
                );
              },
              child: Text(model
                  .randomFeed[widget.index].comments.length ==
                  0
                  ? "No comments"
                  : "View all ${model.randomFeed[widget.index].comments.length} comments")
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
