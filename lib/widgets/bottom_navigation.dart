import 'package:flutter/material.dart';

//import 'package:curved_navigation_bar/curved_navigation_bar.dart';

enum TabItem { home, search, add, activity, profile }

Map<TabItem, String> tabName = {
  TabItem.home: 'Home',
  TabItem.search: 'Search',
  TabItem.add: 'Add',
  TabItem.activity: 'Activity',
  TabItem.profile: 'Profile',
};

Map<TabItem, IconData> tabIcon = {
  TabItem.home: Icons.home,
  TabItem.search: Icons.search,
  TabItem.add: Icons.add_box,
  TabItem.activity: Icons.favorite,
  TabItem.profile: Icons.person,
};

class BottomNavigation extends StatelessWidget {
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  BottomNavigation({this.currentTab, this.onSelectTab});

  @override
  Widget build(BuildContext context) {
//    return CurvedNavigationBar(
//        items: [
//          Icon(
//            tabIcon[TabItem.home],
//            color: _colorTabMatching(item: TabItem.home),
//            size: 30,
//          ),
//          Icon(
//            tabIcon[TabItem.search],
//            color: _colorTabMatching(item: TabItem.search),
//            size: 30,
//          ),
//          Icon(
//            tabIcon[TabItem.add],
//            color: _colorTabMatching(item: TabItem.add),
//            size: 30,
//          ),
//          Icon(
//            tabIcon[TabItem.activity],
//            color: _colorTabMatching(item: TabItem.activity),
//            size: 30,
//          ),
//          Icon(
//            tabIcon[TabItem.profile],
//            color: _colorTabMatching(item: TabItem.profile),
//            size: 30,
//          ),
//        ],
//        onTap: (index) {
//          onSelectTab(
//            TabItem.values[index],
//          );
//        },
//      color: Colors.black54,
//    backgroundColor: Colors.black54,
//      buttonBackgroundColor: Colors.yellow,
//    );

    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          _buildItem(tabItem: TabItem.home),
          _buildItem(tabItem: TabItem.search),
          _buildItem(tabItem: TabItem.add),
          _buildItem(tabItem: TabItem.activity),
          _buildItem(tabItem: TabItem.profile),
        ],
        onTap: (index) { onSelectTab(
          TabItem.values[index],
        );}
    );
  }

  BottomNavigationBarItem _buildItem({TabItem tabItem}) {
    IconData icon = tabIcon[tabItem];
    return BottomNavigationBarItem(
        icon: Icon(
          icon,
          color: _colorTabMatching(item: tabItem),
          size: 30,
        ),
        title: Text("")
    );
  }

  Color _colorTabMatching({TabItem item}) {
    return currentTab == item ? Colors.black87 : Colors.grey;
  }
}
