import 'package:brainsync/pages/Administation/login.dart';
import 'package:brainsync/pages/Administation/register.dart';
import 'package:brainsync/pages/Modules/saved.dart';
import 'package:brainsync/pages/Profile/edit_profile.dart';
import 'package:brainsync/pages/Profile/profile.dart';
import 'package:brainsync/pages/home.dart';
import 'package:brainsync/pages/notifications.dart';
import 'package:brainsync/testing.dart';
import 'package:flutter/material.dart';

import '../pages/Chats/friends_chat.dart';
import '../pages/Modules/all_mods.dart';
import '../pages/Posts/post.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => const LoginPage(),
    "/register": (context) => const RegisterPage(),
    "/home": (context) => const Home(),
    "/profile": (context) => const Profile(),
    "/editProfile": (context) => const EditProfilePage(),
    "/post": (context) => PostsPage(),
    "/friendsChat": (context) => FriendsChats(),
    "/testing": (context) => const Testing(),
    "/notifications": (context) => const Notifications(),
    "/nusMods": (context) => const ModuleListPage(),
    "/saved" : (context) => const Saved(),
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
