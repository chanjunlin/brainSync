import 'package:brainsync/pages/home.dart';
import 'package:brainsync/pages/login.dart';
import 'package:brainsync/common_widgets/bottomBar.dart';
import 'package:brainsync/pages/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pages/chat.dart';
import '../pages/profile.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => LoginPage(),
    "/home": (context) => Home(),
    "/profile": (context) => Profile(),
    "/register": (context) => RegisterPage(),
    "/chat": (context) => ChatPage(),
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

  void pushNamed(String routeName) {
    _navigatorKey.currentState?.pushNamed(routeName);
  }

  void pushReplacementNamed(String routeName) {
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() {
    _navigatorKey.currentState?.pop();
  }

  Future<void> pushName(String routeName) async {
    await _navigatorKey.currentState?.push(
      PageRouteBuilder(
        pageBuilder: (BuildContext context,
            Animation<double> animation1,
            Animation<double> animation2) {
          // Use the route name to retrieve the corresponding widget builder
          final pageBuilder = routes[routeName];
          if (pageBuilder != null) {
            return pageBuilder(context); // Call the builder function to get the widget
          } else {
            // Handle if the route name is not found in routes map
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
        pageBuilder: (BuildContext context,
            Animation<double> animation1,
            Animation<double> animation2) {
          // Use the route name to retrieve the corresponding widget builder
          final pageBuilder = routes[routeName];
          if (pageBuilder != null) {
            return pageBuilder(context); // Call the builder function to get the widget
          } else {
            // Handle if the route name is not found in routes map
            throw Exception('Route "$routeName" not found');
          }
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
