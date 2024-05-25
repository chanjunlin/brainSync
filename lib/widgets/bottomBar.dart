import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';

import '../pages/home.dart';
import '../pages/profile.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final GetIt _getIt = GetIt.instance;

  int myIndex = 0;

  List<Widget> widgetList = [
    Text("asd"),
    Text('How are you'),
    Text('hii'),
    Text('How asdasdare you'),
  ];

  late AuthService _authService;
  late NavigationService _navigationService;

  final User? user = AuthService().currentUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'BrainSync',
          style: TextStyle(),
        ),
      ),
      body: Center(
        child: widgetList[myIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        backgroundColor: Colors.black,
        currentIndex: myIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chats',
              backgroundColor: Colors.red),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code),
              label: 'QR',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_2),
              label: 'Profile',
              backgroundColor: Colors.black),
        ],
      ),
    );
  }
}
