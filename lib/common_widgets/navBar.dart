import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../const.dart';
import '../services/alert_service.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;

  String? userProfilePfp, userProfileCover, firstName, lastName;
  List? friendReqList, currentModules, completedModules;

  final GetIt _getIt = GetIt.instance;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.brown[300],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: userProfilePfp != null
                      ? NetworkImage(userProfilePfp!)
                      : NetworkImage(PLACEHOLDER_PFP),
                ),
                const SizedBox(height: 10),
                Text(
                  firstName ?? 'No Name',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text("See all modules"),
            onTap: () {
              _navigationService.pushName("/nusMods");
            },
          ),
          ListTile(
            title: const Text("Bookmark posts"),
            onTap: () {
              _navigationService.pushName("/saved");
            },
          )
        ],
      ),
    );
  }

  void loadProfile() async {
    try {
      DocumentSnapshot? userProfile = await _databaseService.fetchCurrentUser();
      if (userProfile != null && userProfile.exists) {
        setState(() {
          userProfilePfp = userProfile.get('pfpURL') ?? PLACEHOLDER_PFP;
          userProfileCover =
              userProfile.get('profileCoverURL') ?? PLACEHOLDER_PROFILE_COVER;
          firstName = userProfile.get('firstName') ?? 'Name';
          lastName = userProfile.get('lastName') ?? 'Name';
          friendReqList = userProfile.get("friendReqList") ?? [];
          currentModules = userProfile.get("currentModules") ?? [];
          completedModules = userProfile.get("completedModules") ?? [];
        });
      } else {
        _alertService.showToast(
          text: 'User profile not found',
          icon: Icons.error,
        );
      }
    } catch (e) {
      _alertService.showToast(
        text: 'Error loading profile: $e',
        icon: Icons.error,
      );
    }
  }
}
