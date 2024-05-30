import 'package:brainsync/pages/edit_profile.dart';
import 'package:brainsync/pages/home.dart';
import 'package:brainsync/pages/login.dart';
import 'package:brainsync/pages/register.dart';
import 'package:brainsync/testing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pages/add_friend.dart';
import '../pages/chat_home.dart';
import '../pages/friends_chat.dart';
import '../pages/profile.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => LoginPage(),
    "/register": (context) => RegisterPage(),
    "/home": (context) => Home(),
    "/profile": (context) => Profile(),
    "/editProfile": (context) => EditProfilePage(),
    "/chat": (context) => ChatHomePage(),
    "/addFriends": (context) => AddFriend(),
    "/friendsChat": (context) => FriendsChats(),
    "/testing": (context) => Testing(),
  };

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
  }

  GlobalKey<NavigatorState>? get navigatorKey {
    return _navigatorKey;
  }

  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  void goBack() {
    _navigatorKey.currentState?.pop();
  }

  Future<void> pushName(String routeName) async {
    await _navigatorKey.currentState?.push(
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation1,
            Animation<double> animation2) {
          final pageBuilder = routes[routeName];
          if (pageBuilder != null) {
            return pageBuilder(context);
          } else {
            throw Exception('Route "$routeName" not found');
          }
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Future<void> pushReplacementName(String routeName) async {
    await _navigatorKey.currentState?.pushReplacement(
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation1,
            Animation<double> animation2) {
          final pageBuilder = routes[routeName];
          if (pageBuilder != null) {
            return pageBuilder(context);
          } else {
            throw Exception('Route "$routeName" not found');
          }
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void push(MaterialPageRoute route) {
    _navigatorKey.currentState?.push(
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation1,
            Animation<double> animation2) {
          return route.builder(context);
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
