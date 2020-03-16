import 'package:flutter/material.dart';

import '../../models/comment.dart';
import '../profile/others_profile_page.dart';

class CommentsPage extends StatefulWidget {
  final String username;
  final String caption;
  final String creatorId;
//  final String imageUrl;
  final List<Comment> comments;

  CommentsPage(this.username,this.creatorId,this.caption, this.comments);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CommentsPage();
  }
}

class _CommentsPage extends State<CommentsPage> {
  @override
  Widget build(BuildContext context) {

//    print(widget.comments[0].commentCreatorId);
//    print(widget.comments[0].comment);
//    print(widget.comments[0].username);
//    print(widget.comments[0].id);
//    print(widget.comments[0].postedOn);

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            ListTile(
//              leading: CircleAvatar(
//                backgroundColor: Colors.black38,
//                backgroundImage: widget.imageUrl == null
//                    ? AssetImage("assets/defaultDP.jpg")
//                    : NetworkImage(
//                        widget.imageUrl,
//                      ),
//              ),
              title: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 17, color: Colors.black87),
                  children: [
                    TextSpan(
                      text: widget.username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: widget.caption),
                  ],
                ),
              ),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
//                    leading: CircleAvatar(
//                      backgroundColor: Colors.black38,
//                      backgroundImage: widget
//                                  .comments[index].author.profile_imageUrl ==
//                              null
//                          ? AssetImage("assets/defaultDP.jpg")
//                          : NetworkImage(
//                              widget.comments[index].author.profile_imageUrl),
//                    ),
                    title: Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OtherProfilePage(
                                  widget.comments[index].commentCreatorId),
                            ),
                          ),
                          child: Text(
                            widget.comments[index].username,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          widget.comments[index].comment,
                          style: TextStyle(fontSize: 17, color: Colors.black87),
                        ),
                      ],
                    ),
                    subtitle: Text("${DateTime.now().difference(
                          DateTime.parse(widget.comments[index].postedOn),
                        ).inMinutes}m ago"),
                  );
                },
                itemCount: widget.comments.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
