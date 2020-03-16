import 'package:flutter/material.dart';
import 'package:async/async.dart';

import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../widgets/grid_card.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
import 'followers_page.dart';
import 'following_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProfilePage();
  }
}

class _ProfilePage extends State<ProfilePage> {
  var _isInit = true;
  var _isLoading = false;
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

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    try {
      if (_isInit) {
        _memoizer.runOnce(() async {
          setState(() {
            _isLoading = true;
          });
          await Provider.of<ProfileProvider>(context)
              .fetchProfile(context, 0, "312");
          _isLoading = false;
          _isInit = false;
        });
        _isInit = false;
      }
      _isInit = false;
    } catch (error) {
      var errorMessage = "Could not fetch Data! Try again later";
      _showErrorDialog(context, errorMessage);
    }
    super.didChangeDependencies();
  }

  Future<void> _updateProfileFeed() async {
    await Provider.of<ProfileProvider>(context).fetchProfile(context, 0, "312");
    Fluttertoast.showToast(
        msg: "Profile Refreshed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ProfileProvider>(context);

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? "My Profile" : model.userProfile.username),
        actions: <Widget>[
          FlatButton(
            child: Text("Logout"),
            onPressed: () {Provider.of<AuthProvider>(context).logout();},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _updateProfileFeed,
        child: _isLoading
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
                                GestureDetector(
                                  onLongPress: () {
                                    return showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Card(
                                              color: Colors.purple,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                              ),
                                              elevation: 10,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                child: model.userProfile.profileImageUrl ==
                                                    null ? Image.asset(
                                                    "assets/default.jpg") : Image.network("${model.ngrokUrl}/images/${model.userProfile.profileImageUrl.substring(7)}"),
                                              ),
                                            ),
//                                            content: Container(
//                                              child: SingleChildScrollView(
//                                                child: Column(
//                                                  children: <Widget>[
//                                                    SizedBox(
//                                                      height: 3,
//                                                    ),
//                                                  ],
//                                                ),
//                                              ),
//                                            ),
                                          );
                                        });
                                  },
                                  child: model.userProfile.profileImageUrl ==
                                          null
                                      ? CircleAvatar(
                                          radius: 50,
                                          backgroundImage:
                                              AssetImage("assets/default.jpg"),
                                        )
                                      : CircleAvatar(
                                          radius: 50,
                                          backgroundImage: NetworkImage(
                                              "${model.ngrokUrl}/images/${model.userProfile.profileImageUrl.substring(7)}"),
                                        ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  model.userProfile.name,
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    model.userProfile.bio,
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
                                            model.userProfile.posts.length
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
                                                model.userProfile.followers),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            model.userProfile.followerCount
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
                                                model.userProfile.following),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            model.userProfile.followingCount
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
                                  "Edit Profile",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => EditProfilePage(),
                                    ),
                                  );
                                },
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
                        return GridCard(model.userProfile.posts[index].imageUrl,
                            index, 0, "profile");
                      }, childCount: model.userProfile.posts.length),
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
      ),
    );
  }
}
