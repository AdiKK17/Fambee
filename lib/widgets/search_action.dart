import 'package:flutter/material.dart';
import 'package:async/async.dart';

import 'package:provider/provider.dart';

import '../providers/search_provider.dart';
import '../providers/profile_provider.dart';

import '../pages/profile/others_profile_page.dart';

class ProfileSearch extends SearchDelegate<String> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  bool _isloading = false;

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: () => query = ""),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _memoizer.runOnce(() async {
      await Provider.of<SearchProvider>(context)
          .fetchSearchResults(context, query);
    });

    return Provider.of<SearchProvider>(context).userList.length == 0
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.all(10),
                color: Colors.black12,
                child: ListTile(
                  contentPadding: EdgeInsets.all(20),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OtherProfilePage(
                            Provider.of<SearchProvider>(context)
                                .userList[index]
                                .id),
                      ),
                    );
                  },
//            leading: CircleAvatar(
//              radius: 30.0,
//              backgroundImage: NetworkImage(
//                  Provider.of<SearchedRecipes>(context)
//                      .searchedItems[index]
//                      .imageUrl),
//            ),
                  title: Text(
                    Provider.of<SearchProvider>(context)
                        .userList[index]
                        .username,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(Provider.of<SearchProvider>(context)
                      .userList[index]
                      .name),
                ),
              );
            },
            itemCount: Provider.of<SearchProvider>(context).userList.length,
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return query.isEmpty
        ? Container(
            child: Center(
              child: Text(
                "Search user by name!",
                style: TextStyle(fontSize: 20),
              ),
            ),
          )
        : Container(
            child: Center(
              child: Text("Hit Enter for results"),
            ),
          );
  }
}
