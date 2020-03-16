import 'package:flutter/material.dart';

import '../../models/followFollowing.dart';
import 'others_profile_page.dart';

class FollowingPage extends StatelessWidget {
  final List<FollowFollowing> following;

  FollowingPage(this.following);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Following"),
      ),
      body: following.length == 0
          ? Center(
        child: Text(
          "Not following anyone",
          style: TextStyle(fontSize: 30,fontFamily: "Montserrat"),
        ),
      )
          : Container(
        child: ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder:(context) => OtherProfilePage(following[index].id))),
              title: Text(
                following[index].username,
              ),
              subtitle: Text(
                following[index].name,
              ),
            );
          },
          itemCount: following.length,
        ),
      ),
    );
  }
}
