import 'package:brainsync/common_widgets/bottomBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../const.dart';
import '../../model/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/navigation_service.dart';

class FriendsChats extends StatefulWidget {
  @override
  _FriendsChatsState createState() => _FriendsChatsState();
}

class _FriendsChatsState extends State<FriendsChats> {
  final GetIt _getIt = GetIt.instance;

  late NavigationService _navigationService;
  late DatabaseService _databaseService;
  late AuthService _authService;

  bool hasChats = false;
  bool presentChat = false;

  List<UserProfile?> allFriends = [];
  List<UserProfile?> filteredFriends = [];
  List? friendReqList, currentModules, completedModules, chats;

  String? userProfilePfp, userProfileCover, firstName, lastName;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _databaseService = _getIt.get<DatabaseService>();
    loadProfile();
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
          currentModules = userProfile.get("currentModule") ?? [];
          completedModules = userProfile.get("completedModule") ?? [];
          chats = userProfile.get("chats") ?? [];
          hasChats = chats!.isNotEmpty;
        });
      } else {
        print('User profile not found');
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends & Chats'),
        automaticallyImplyLeading: false,
      ),
      body: hasChats
          ? ListView.builder(
        itemCount: chats?.length ?? 0,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Chat ${chats![index]}'),
            onTap: () {
              // Handle chat item tap
            },
          );
        },
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No chats!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
              },
              child: Text('Create a chat'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 1),
    );
  }
}
