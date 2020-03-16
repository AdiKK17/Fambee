import 'package:flutter/material.dart';
import 'package:async/async.dart';

import 'package:provider/provider.dart';

import '../../widgets/grid_card.dart';
import '../../providers/profile_provider.dart';
import 'followers_page.dart';
import 'following_page.dart';

class OtherProfilePage extends StatefulWidget {
  final String userId;

  OtherProfilePage(this.userId);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _OtherProfilePage();
  }
}

class _OtherProfilePage extends State<OtherProfilePage> {
  var _isInit = true;
  var _isLoading = false;

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

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Are you sure?"),
        content: Text(
            "You want to unfollow ${Provider.of<ProfileProvider>(context).otherProfile.name}?"),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<ProfileProvider>(context, listen: false)
                  .toggleFollowFollowing(widget.userId);
            },
            child: Text("Unfollow"),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    try {
      if (_isInit) {
        setState(() {
          _isLoading = true;
        });
        Provider.of<ProfileProvider>(context)
            .fetchProfile(context, 1, widget.userId)
            .then((_) {
          _isLoading = false;
          setState(() {
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
  Widget build(BuildContext context) {
    final model = Provider.of<ProfileProvider>(context);

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? "Profile" : model.otherProfile.username),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              backgroundColor: Colors.black,
            ))
          : Container(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          color: Colors.purple,
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                model.otherProfile.name,
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontSize: 22,
                                    color: Colors.white),
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  model.otherProfile.bio,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w200,
                                      color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  GestureDetector(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          model.otherProfile.posts.length
                                              .toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          "Posts",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        )
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => FollowerPage(
                                              model.otherProfile.followers),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          model.otherProfile.followerCount
                                              .toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          "Followers",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        )
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => FollowingPage(
                                              model.otherProfile.following),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          model.otherProfile.followingCount
                                              .toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          "Following",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                              color: Colors.cyan,
                              child: Text(
                                Provider.of<ProfileProvider>(context)
                                        .otherProfile
                                        .isBeingFollowed
                                    ? "Following"
                                    : "Follow",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                Provider.of<ProfileProvider>(context,
                                            listen: false)
                                        .otherProfile
                                        .isBeingFollowed
                                    ? _showConfirmDialog()
                                    : Provider.of<ProfileProvider>(context,
                                            listen: false)
                                        .toggleFollowFollowing(widget.userId);
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            RaisedButton(
                              color: Colors.black54,
                              onPressed: () {},
                              child: Text(
                                "Message",
                                style: TextStyle(color: Colors.white),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                  SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return GridCard(model.otherProfile.posts[index].imageUrl,
                          index, 1, "profile");
                    }, childCount: model.otherProfile.posts.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
