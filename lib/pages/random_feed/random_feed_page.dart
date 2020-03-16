import 'package:flutter/material.dart';
import 'package:async/async.dart';

import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../providers/random_feed_provider.dart';
import '../../widgets/grid_card.dart';
import '../../widgets/search_action.dart';

class RandomFeedPage extends StatefulWidget {
  final BuildContext rootContext;

  RandomFeedPage(this.rootContext);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RandomFeedPage();
  }
}

class _RandomFeedPage extends State<RandomFeedPage> {
  var _isInit = true;
  var _isLoading = false;

  final AsyncMemoizer _memoizer = AsyncMemoizer();
  ScrollController _scrollController = ScrollController();

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

//  @override
//  void didChangeDependencies() {
//    // TODO: implement didChangeDependencies
//    try {
//      if (_isInit) {
//        setState(() {
//          _isLoading = true;
//        });
//        Provider.of<RandomFeedProvider>(context).fetchRandomFeed().then((_) {
//          _isLoading = false;
//          setState(() {
//            _isInit = false;
//          });
//        });
//      }
//    } catch (error) {
//      var errorMessage = "Could not fetch Data! Try again later";
//      _showErrorDialog(context, errorMessage);
//    }
//    super.didChangeDependencies();
//  }

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
          await Provider.of<RandomFeedProvider>(context).fetchRandomFeed();
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

  void _appendPosts() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      Provider.of<RandomFeedProvider>(context, listen: false).addToRandomFeed();
    }
  }

  Future<void> _refreshRandomFeed() async {
    await Provider.of<RandomFeedProvider>(context).fetchRandomFeed();
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
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Explore"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: ProfileSearch(),
                );
              }),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          :
//      Provider.of<RandomFeedProvider>(context)
//          .randomFeed
//          .length == 0 ? Center(child: Text("No Posts",style: TextStyle(fontSize: 30,color: Colors.grey),),)
           Container(
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              color: Colors.white,
              child: RefreshIndicator(
                onRefresh: _refreshRandomFeed,
                child: GridView.builder(
                  controller: _scrollController,
                  itemCount: Provider.of<RandomFeedProvider>(context)
                      .randomFeed
                      .length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GridCard(
                        Provider.of<RandomFeedProvider>(context)
                            .randomFeed[index]
                            .imageUrl,
                        index,
                        2,
                        "random");
                  },
                ),
              ),
            ),
    );
  }
}
