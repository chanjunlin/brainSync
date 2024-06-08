import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late User? user;
  late DatabaseService _databaseService;
  late AuthService _authService;
  late NavigationService _navigationService;

  final GetIt _getIt = GetIt.instance;

  @override
  void initState() {
    _databaseService = _getIt.get<DatabaseService>();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    user = _authService.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    print(user);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0),
        children: [
          UserAccountsDrawerHeader(
            accountName: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${user?.displayName}"),
              ],
            ),
            accountEmail: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${user?.email}"),
              ],
            ),
            currentAccountPicture: CircleAvatar(),
          ),
          ElevatedButton(
            onPressed: () {
              _navigationService.pushName("/allUsers");
            },
            child: Text("See all users"),
          ),
          ElevatedButton(
            onPressed: () {
              _navigationService.pushName("/nusMods");
            },
            child: Text("See all mods"),
          ),
        ],
      ),
    );
  }
}
