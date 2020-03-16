import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import './providers/auth_provider.dart';
import './providers/home_feed_provider.dart';
import './providers/profile_provider.dart';
import './providers/random_feed_provider.dart';
import './providers/search_provider.dart';
import './pages/authentication/auth_page.dart';
import './pages/main_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AuthProvider(),
        ),
        ChangeNotifierProvider.value(
          value: PostProvider(),
        ),
        ChangeNotifierProvider.value(
          value: ProfileProvider(),
        ),
        ChangeNotifierProvider.value(
          value: RandomFeedProvider(),
        ),
        ChangeNotifierProvider.value(
          value: SearchProvider(),
        ),
      ],
      child:
      Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.purple,
          ),
//        home: MainPage(),
          home: auth.isAuthenticated
              ? MainPage()
              : FutureBuilder(
            future: auth.autoLogin(),
            builder: (context, authResult) =>
            authResult.connectionState == ConnectionState.waiting
                ? Scaffold(
              body: Center(
                child: Text("Insta"),
              ),
            )
                : AuthPage(),
          ),
        ),
      ),

    );

  }
}

