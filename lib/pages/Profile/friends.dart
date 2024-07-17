import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../const.dart';
import '../../model/user_profile.dart';
import '../../services/database_service.dart';

class FriendListPage extends StatefulWidget {
  final List<UserProfile?> friendList;

  const FriendListPage({
    super.key,
    required this.friendList,
  });

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  late DatabaseService _databaseService;

  String? userProfilePfp, userProfileCover, firstName, lastName;
  List? friendReqList;

  @override
  void initState() {
    super.initState();
    _databaseService = GetIt.instance.get<DatabaseService>();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.friendList.length,
        itemBuilder: (context, index) {
          UserProfile? userProfile = widget.friendList[index];
          return ListTile(
            title: Text(userProfile?.firstName ?? ''),
            subtitle: Text(userProfile?.lastName ?? ''),
          );
        },
      ),
    );
  }

  void loadProfile() async {
    try {
      final userProfile = await _databaseService.fetchCurrentUser();
      if (userProfile != null && userProfile.exists) {
        setState(() {
          userProfilePfp = userProfile.get('pfpURL') ?? PLACEHOLDER_PFP;
          userProfileCover = userProfile.get('profileCoverURL') ?? PLACEHOLDER_PROFILE_COVER;
          firstName = userProfile.get('firstName') ?? 'Name';
          lastName = userProfile.get('lastName') ?? 'Name';
          friendReqList = userProfile.get("friendReqList") ?? [];
        });
      } else {
        print('User profile not found');
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }
}
