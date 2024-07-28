import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../pages/Profile/visiting_profile/visiting_profile.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class FriendRequestCard extends StatefulWidget {
  final dynamic userData;

  const FriendRequestCard({
    super.key,
    required this.userData,
  });

  @override
  State<FriendRequestCard> createState() => _FriendRequestCardState();
}

class _FriendRequestCardState extends State<FriendRequestCard> {
  final GetIt _getIt = GetIt.instance;

  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;

  late dynamic userData;

  late List<dynamic> friendReqList;

  late Future<void> loadedProfile;

  @override
  void initState() {
    super.initState();
    userData = widget.userData;
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    loadedProfile = loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VisitProfile(userId: userData["id"]),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundImage: NetworkImage(userData['pfpURL']),
        ),
        title: Text(userData['firstName']),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                await _databaseService.acceptFriendRequest(
                    userData["uid"], _authService.currentUser!.uid);
                if (mounted) {
                  setState(() {
                    friendReqList.remove(userData["uid"]);
                  });
                }
                _alertService.showToast(
                  text: "Friend Accepted",
                  icon: Icons.check,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                await _databaseService.rejectFriendRequest(
                    userData["uid"], _authService.currentUser!.uid);
                if (mounted) {
                  setState(() {
                    friendReqList.remove(userData["uid"]);
                  });
                }
                _alertService.showToast(
                  text: "Friend Request Rejected",
                  icon: Icons.close,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadProfile() async {
    DocumentSnapshot? userProfile = await _databaseService.fetchCurrentUser();
    if (userProfile != null && userProfile.exists) {
      if (mounted) {
        setState(() {
          friendReqList = userProfile.get('friendReqList') ?? [];
        });
      }
    } else {
      _alertService.showToast(text: 'User profile not found');
    }
  }
}
