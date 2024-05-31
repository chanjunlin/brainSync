import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../common_widgets/bottomBar.dart';
import '../const.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/navigation_service.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final GetIt _getIt = GetIt.instance;
  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;

  String? userProfilePfp, userProfileCover, firstName, lastName;
  List? friendReqList;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();

    loadProfile(); // Call loadProfile() in initState()
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: buildFriendRequests(),
      bottomNavigationBar: CustomBottomNavBar(initialIndex: 3),
    );
  }

  Widget buildFriendRequests() {
    if (friendReqList == null || friendReqList!.isEmpty) {
      return Center(
        child: Text(
          'No friend requests',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey, // Adjust color as needed
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: friendReqList!.length,
        itemBuilder: (context, index) {
          return buildFriendRequestTile(friendReqList![index]);
        },
      );
    }
  }

  Widget buildFriendRequestTile(String uid) {
    return FutureBuilder<DocumentSnapshot<Object?>>(
      future: _databaseService.getUserProfile(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('User not found');
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(userData['pfpURL']),
          ),
          title: Text(userData['firstName']),
          trailing: IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              await _databaseService.acceptFriendRequest(
                  uid, _authService.user!.uid);
              setState(() {
                friendReqList!.remove(uid);
              });
            },
          ),
        );
      },
    );
  }

  Widget buildNoNotificationsMessage() {
    return Center(
      child: Text(
        'No notifications',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
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
        });
      } else {
        print('User profile not found');
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }
}
