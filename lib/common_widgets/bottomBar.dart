import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/navigation_service.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int initialIndex;

  const CustomBottomNavBar({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  final NavigationService _navigationService =
      GetIt.instance<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: widget.initialIndex,
      backgroundColor: Colors.transparent,
      buttonBackgroundColor: Colors.brown[300],
      color: Colors.brown.shade300,
      animationDuration: const Duration(milliseconds: 200),
      items: const <Widget>[
        Icon(Icons.home, size: 26, color: Colors.white),
        Icon(Icons.chat, size: 26, color: Colors.white),
        Icon(Icons.add, size: 26, color: Colors.white),
        Icon(Icons.notifications, size: 26, color: Colors.white),
        Icon(Icons.person, size: 26, color: Colors.white),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            _navigationService.pushName("/home");
            break;
          case 1:
            _navigationService.pushName("/friendsChat");
            break;
          case 2:
            _navigationService.pushName("/post");
            break;
          case 3:
            _navigationService.pushName("/notifications");
            break;
          case 4:
            _navigationService.pushName("/profile");
            break;
        }
      },
    );
  }
}
