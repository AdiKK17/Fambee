import 'package:flutter/material.dart';

import '../../models/followFollowing.dart';
import 'others_profile_page.dart';

class FollowerPage extends StatelessWidget {
  final List<FollowFollowing> followers;

  FollowerPage(this.followers);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Followers"),
      ),
      body: followers.length == 0
          ? Center(
              child: Text(
                "No followers",
                style: TextStyle(fontSize: 30, fontFamily: "Montserrat"),
              ),
            )
          : Container(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder:(context) => OtherProfilePage(followers[index].id))),
                    title: Text(
                      followers[index].username,
                    ),
                    subtitle: Text(
                      followers[index].name,
                    ),
                  );
                },
                itemCount: followers.length,
              ),
            ),
    );
  }
}
