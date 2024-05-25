import 'package:brainsync/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {

  final User? user = AuthService().currentUser;

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
            currentAccountPicture: CircleAvatar(

            ),
          ),
        ],
      ),
    );
  }
}
