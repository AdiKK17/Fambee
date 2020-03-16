import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/home_feed_provider.dart';

import '../pages/profile/profile_grid_post_page.dart';
import '../pages/random_feed/random_grid_post_page.dart';

class GridCard extends StatelessWidget {

  final String imageUrl;
  final int index;
  final int num;
  final String page;

  GridCard(this.imageUrl, this.index, this.num,this.page);

  @override
  Widget build(BuildContext context) {

//    print("${Provider.of<PostProvider>(context).ngrokUrl}$imageUrl");

    // TODO: implement build
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => page == "profile" ?  PostPage(index,num) : RandomPostPage(index,num),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey,width: 1,style: BorderStyle.solid),
              borderRadius: BorderRadius.all(Radius.circular(10),),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage("${Provider.of<PostProvider>(context).ngrokUrl}/images/$imageUrl"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
