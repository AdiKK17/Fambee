import 'package:flutter/material.dart';

import '../pages/home/home_page.dart';
import '../pages/random_feed/random_feed_page.dart';
import '../pages/activity/activity_page.dart';
import '../pages/profile/my_profile_page.dart';
import 'bottom_navigation.dart';

class TabNavigator extends StatelessWidget {

  final GlobalKey<NavigatorState> navigatorKey;
  final BuildContext rootContext;
  final TabItem tabItem;

  TabNavigator({this.navigatorKey,this.rootContext,this.tabItem});

  @override
  Widget build(BuildContext context) {

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        if(tabItem == TabItem.home) {
          return MaterialPageRoute(
              builder: (context) =>
                  HomePage(rootContext)
          );
        }else if(tabItem == TabItem.search) {
          return MaterialPageRoute(
              builder: (context) =>
                  RandomFeedPage(rootContext)
          );
        }else if(tabItem == TabItem.activity) {
          return MaterialPageRoute(
              builder: (context) =>
                  UserActivityPage()
          );
        }else if(tabItem == TabItem.profile) {
          return MaterialPageRoute(
              builder: (context) =>
                  ProfilePage()
          );
        }
        return MaterialPageRoute(
            builder: (context) =>
                HomePage(rootContext)
        );
      },
    );
  }
}
