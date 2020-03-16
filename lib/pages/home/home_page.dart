import 'dart:async';

import 'package:flutter/material.dart';
import 'package:async/async.dart';

import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/home_feed_provider.dart';
import 'comments_page.dart';
import '../profile/others_profile_page.dart';

class HomePage extends StatefulWidget {
  final BuildContext rootContext;

  HomePage(this.rootContext);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  VideoPlayerController _videoController;
  VoidCallback _listener;
  bool _muteIt = false;
  bool _showVideoIcons = false;
  bool _showHeartOverlay = false;
  int _previousIndex;

  var _isInit = true;
  var _isLoading = false;
  var _isCommenting = false;
  ScrollController _scrollController = ScrollController();

  final AsyncMemoizer _memoizer = AsyncMemoizer();

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

  ///////////

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    try {
      if (_isInit) {
        _memoizer.runOnce(() async {
          setState(() {
            _isLoading = true;
          });
          _scrollController.addListener(_appendPosts);
          await Provider.of<PostProvider>(context).fetchHomeFeed();
          setState(() {
            _isLoading = false;
            _isInit = false;
          });
        });
      }
    } catch (error) {
      var errorMessage = "Could not fetch Data! Try again later";
      _showErrorDialog(context, errorMessage);
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    // TODO: implement initState
//    _listener = () {
//      setState(() {});
//    };
    super.initState();
  }

  void _appendPosts() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      Provider.of<PostProvider>(context, listen: false).addToHomeFeed();
    }
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    if (_videoController != null) {
      _videoController.setVolume(0.0);
      _videoController.removeListener(_listener);
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (_videoController != null) {
      _videoController.dispose();
    }
    super.dispose();
  }

  ////////////

  void _createVideo(int index) {
    if (_videoController != null) {
      _videoController.dispose();
      _videoController = null;
    }
//    _videoController = VideoPlayerController.asset(
//        Provider.of<TestingProvider>(context).posts[index].postContentUrl)
//      ..addListener(_listener)
//      ..setVolume(1.0)
//      ..setLooping(true)
//      ..initialize();
//    _videoController.play();
  }

  void _showBigHeart(int index) {
    setState(() {
      _showHeartOverlay = true;
      Provider.of<PostProvider>(context, listen: false)
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

  void _showIcons() {
//    setState(() {
//      _showVideoIcons = true;
//      if (_showVideoIcons) {
//        Timer(const Duration(milliseconds: 800), () {
//          setState(() {
//            _showVideoIcons = false;
//          });
//        });
//      }
//    });
  }

  Widget _buildUpperPostComponent(int index) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
             NetworkImage(
          Provider.of<PostProvider>(context)
              .homeFeed[index]
              .profileImageUrl
               ==
              null
              ? ""
              : Provider.of<PostProvider>(context)
              .homeFeed[index]
              .profileImageUrl,
        ),
      ),
//      leading: CircleAvatar(
//        backgroundImage: Provider.of<PostProvider>(context)
//                    .homeFeed[index]
//                    .author
//                    .profile_imageUrl ==
//                null
//            ? AssetImage("assets/defaultDP.jpg")
//            : NetworkImage(
//                Provider.of<PostProvider>(context)
//                            .homeFeed[index]
//                            .author
//                            .profile_imageUrl ==
//                        null
//                    ? ""
//                    : Provider.of<PostProvider>(context)
//                        .homeFeedPosts[index]
//                        .author
//                        .profile_imageUrl,
//              ),
//      ),
//      title: GestureDetector(
//        onTap: () => Navigator.of(context).push(
//          MaterialPageRoute(
//            builder: (context) => OtherProfilePage(
//                Provider.of<PostProvider>(context)
//                    .homeFeedPosts[index]
//                    .author
//                    .username),
//          ),
//        ),
//        child: Text(
//          Provider.of<PostProvider>(context)
//              .homeFeedPosts[index]
//              .author
//              .username,
//          style: TextStyle(fontWeight: FontWeight.bold),
//        ),
//      ),
      title: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtherProfilePage(
                Provider.of<PostProvider>(context).homeFeed[index].postCreatorId),
          ),
        ),
        child: Text(
          Provider.of<PostProvider>(context).homeFeed[index].username,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      subtitle:
          Text(Provider.of<PostProvider>(context).homeFeed[index].location),
    );
  }

  Widget _buildUnplayedVideoImage(int index) {
//    return Stack(
//      alignment: Alignment.center,
//      children: <Widget>[
//        Container(
//          color: Colors.tealAccent,
//          width: double.infinity,
//        ),
//        IconButton(
//          icon: Icon(
//            Icons.play_arrow,
//            size: 50,
//          ),
//          onPressed: () {
//            if (_previousIndex != null) {
//              Provider.of<TestingProvider>(context)
//                  .posts[_previousIndex]
//                  .playVideo = false;
//            }
//            _previousIndex = index;
//            _createVideo(index);
//            setState(() {
//              Provider.of<TestingProvider>(context).posts[index].playVideo =
//                  true;
//            });
//          },
//        ),
//      ],
//    );
  }

  Widget _buildVideoPlayer(int index) {
//    return Stack(
//      alignment: Alignment.center,
//      children: <Widget>[
//        VideoPlayer(_videoController),
//        _showHeartOverlay
//            ? Icon(
//                Icons.favorite,
//                size: 80,
//                color: Colors.white,
//              )
//            : Container(),
//        _showVideoIcons
//            ? Positioned(
//                child: Icon(
//                  _muteIt ? Icons.volume_off : Icons.volume_up,
//                  color: Colors.white,
//                  size: 15,
//                ),
//                bottom: 10,
//                right: 10,
//              )
//            : Container(),
//        _showVideoIcons
//            ? _videoController.value.isBuffering
//                ? Positioned(
//                    top: 10,
//                    right: 10,
//                    child: CircularProgressIndicator(
//                      backgroundColor: Colors.white,
//                      strokeWidth: 2,
//                    ),
//                  )
//                : Container()
//            : Container(),
//      ],
//    );
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
              imageUrl:
                  "${Provider.of<PostProvider>(context).ngrokUrl}/images/${Provider.of<PostProvider>(context).homeFeed[index].imageUrl}",
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
          icon: Icon(Provider.of<PostProvider>(context, listen: false)
                  .homeFeed[index]
                  .isLiked
              ? Icons.favorite
              : Icons.favorite_border),
          iconSize: 30,
          onPressed: () {
            Provider.of<PostProvider>(context, listen: false)
                .toggleFavoriteStatus(index);
          },
        ),
        SizedBox(
          width: 4,
        ),
        Text(
          Provider.of<PostProvider>(context, listen: false)
              .homeFeed[index]
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
                  Provider.of<PostProvider>(context).homeFeed[index].username,
                    Provider.of<PostProvider>(context).homeFeed[index].postCreatorId,
                  "  ${Provider.of<PostProvider>(context).homeFeed[index].caption}",
                  Provider.of<PostProvider>(context).homeFeed[index].comments,
                ),
              ),
            );
          },
        ),
        Spacer(),
//        IconButton(
//          icon: Icon(Icons.save),
//          iconSize: 30,
//          onPressed: () {},
//        ),
      ],
    );
  }

  Widget _buildCaption(BuildContext context, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: Provider.of<PostProvider>(context).homeFeed[index].username,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
                text:
                    "  ${Provider.of<PostProvider>(context).homeFeed[index].caption}")
          ],
        ),
      ),
    );
  }

  Widget _buildCommentTextField(int index) {
    TextEditingController _textEditingController = TextEditingController();

    return ListTile(
//      leading: CircleAvatar(
//        radius: 15,
//        backgroundImage: Provider.of<PostProvider>(context)
//                    .homeFeed[index]
//                    .author
//                    .profile_imageUrl ==
//                null
//            ? AssetImage("assets/defaultDP.jpg")
//            : NetworkImage(
//                Provider.of<PostProvider>(context)
//                            .homeFeedPosts[index]
//                            .author
//                            .profile_imageUrl ==
//                        null
//                    ? ""
//                    : Provider.of<PostProvider>(context)
//                        .homeFeedPosts[index]
//                        .author
//                        .profile_imageUrl,
//              ),
//      ),
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

          await Provider.of<PostProvider>(context, listen: false).addComment(context,
              Provider.of<PostProvider>(context, listen: false)
                  .homeFeed[index]
                  .id,
              comment);

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

  Future<void> _refreshHomeFeed() async {
    await Provider.of<PostProvider>(context, listen: false).fetchHomeFeed();
    Fluttertoast.showToast(
        msg: "Feed Refreshed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<PostProvider>(context);

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Instagram"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshHomeFeed,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : model.homeFeed.length == 0 ? Center(child: Text("No Posts",style: TextStyle(fontSize: 30,color: Colors.grey),),) : ListView.builder(
                controller: _scrollController,
                itemBuilder: (BuildContext context, int index) {
                  if (index == model.homeFeed.length) {
//                    if(model.noMorePosts){
//                      print("its here");
//                      return Container();
//                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildUpperPostComponent(index),
                      AspectRatio(
                        aspectRatio: 1,
                        child: GestureDetector(
                          onDoubleTap: () {
                            _showBigHeart(index);
                          },
//                            onTap: () {
//                              if (Provider.of<TestingProvider>(context)
//                                  .posts[index]
//                                  .playVideo) {
//                                if (Provider.of<TestingProvider>(context)
//                                    .posts[index]
//                                    .postContentUrl
//                                    .contains(".mp4")) {
//                                  _showIcons();
//                                  _muteIt = !_muteIt;
//                                  _muteIt
//                                      ? _videoController.setVolume(0.0)
//                                      : _videoController.setVolume(1.0);
//                                }
//                              }
//                            },
                          child:
//                            Provider.of<TestingProvider>(context)
//                                    .posts[index]
//                                    .postContentUrl
//                                    .contains(".mp4")
//                                ? !Provider.of<TestingProvider>(context)
//                                        .posts[index]
//                                        .playVideo
//                                    ? _buildUnplayedVideoImage(index)
//                                    : _buildVideoPlayer(index)
//                                :
                              _buildPostImage(index),
                        ),
                      ),
                      _buildLikeCommentRow(index),
                      _buildCaption(context, index),
                      FlatButton(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CommentsPage(
                              model.homeFeed[index].username,
                              Provider.of<PostProvider>(context).homeFeed[index].username,
                              "  ${model.homeFeed[index].caption}",
                              model.homeFeed[index].comments,
                            ),
                          ),
                        ),
                        child: Text(model.homeFeed[index].comments.length == 0
                            ? "No comments"
                            : "View all ${model.homeFeed[index].comments.length} comments"),
                      ),
                      _isCommenting
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : _buildCommentTextField(index),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        color: Colors.black54,
                        indent: 30,
                        endIndent: 30,
                      )
                    ],
                  );
                },
                itemCount: model.homeFeed.length + 1,
              ),
      ),
    );
  }
}
