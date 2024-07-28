import 'dart:async';

import 'package:brainsync/common_widgets/friend_request_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../common_widgets/bottomBar.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final GetIt _getIt = GetIt.instance;
  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;

  String firstName = 'First';
  String lastName = 'Last';
  bool isFriendRequestSent = false;
  List? friendReqList = [];
  bool isFriend = false;

  late StreamSubscription<DocumentSnapshot> friendRequestStream;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _authService = _getIt.get<AuthService>();
    loadProfile();
  }

  @override
  void dispose() {
    friendRequestStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: buildNotifications(),
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 3),
    );
  }

  Widget buildNotifications() {
    if (friendReqList == null || friendReqList!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/img/happy_brain.png"),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 20,
                color: Colors.brown[700],
              ),
            ),
          ],
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
    return StreamBuilder<DocumentSnapshot<Object?>>(
      stream: _databaseService.getUserProfile(uid),
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
        return FriendRequestCard(userData: userData);
      },
    );
  }

  void loadProfile() async {
    try {
      friendRequestStream = _databaseService
          .getUserProfile(_authService.currentUser!.uid)
          .listen((userProfile) {
        if (userProfile.exists) {
          var data = userProfile.data() as Map<String, dynamic>;
          setState(() {
            firstName = data['firstName'] ?? 'First';
            lastName = data['lastName'] ?? 'Last';
            friendReqList = List<String>.from(data['friendReqList'] ?? []);
            List friendList = data['friendList'] ?? [];
            isFriend = friendList.contains(_authService.currentUser!.uid);
            isFriendRequestSent =
                friendReqList!.contains(_authService.currentUser!.uid);
          });
        } else {
          _alertService.showToast(
              text: "User profile not found",
              icon: Icons.error_outline_rounded);
        }
      });
    } catch (e) {
      _alertService.showToast(
        text: '$e',
        icon: Icons.error,
      );
    }
  }
}
