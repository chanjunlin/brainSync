import 'dart:async';

import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../common_widgets/dialog.dart';
import '../../const.dart';
import '../../model/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import 'friends.dart';

class VisitProfile extends StatefulWidget {
  final String userId;

  VisitProfile({required this.userId});

  @override
  State<VisitProfile> createState() => _VisitProfileState();
}

class _VisitProfileState extends State<VisitProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;

  String userProfilePfp = PLACEHOLDER_PFP;
  String userProfileCover = PLACEHOLDER_PROFILE_COVER;
  String firstName = 'First';
  String lastName = 'Last';
  String bio = 'No bio available';
  bool isFriendRequestSent = false;
  bool isFriend = false;
  List? friendReqList, friendList, currentModules, completedModules;

  late StreamSubscription<DocumentSnapshot> profileStream;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
    loadProfile();
  }

  @override
  void dispose() {
    profileStream.cancel();
    super.dispose();
  }

  void loadProfile() async {
    try {
      profileStream =
          _databaseService.getUserProfile(widget.userId).listen((userProfile) {
        if (userProfile.exists) {
          var profile = userProfile.data() as Map<String, dynamic>;
          setState(() {
            userProfilePfp = profile['pfpURL'] ?? PLACEHOLDER_PFP;
            userProfileCover =
                profile['profileCoverURL'] ?? PLACEHOLDER_PROFILE_COVER;
            firstName = profile['firstName'] ?? 'First';
            lastName = profile['lastName'] ?? 'Last';
            bio = profile['bio'] ?? 'No bio available';
            currentModules = profile["currentModule"] ?? [];
            completedModules = profile["completedModule"] ?? [];
            friendReqList = profile['friendReqList'] ?? [];
            friendList = profile['friendList'] ?? [];
            isFriend = friendList!.contains(_authService.currentUser!.uid);
            isFriendRequestSent =
                friendReqList!.contains(_authService.currentUser!.uid);
          });
        } else {
          _alertService.showToast(
            text: "User profile not found",
            icon: Icons.error,
          );
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        title: Text('User Profile'),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          buildTop(),
          buildProfileInfo(),
          Divider(),
          buildTabBarSection(), // Add this line
        ],
      ),
    );
  }

  Widget buildTop() {
    final double coverHeight = 280;
    final double profileHeight = 144;
    final double bottom = profileHeight / 2;
    final double top = coverHeight - profileHeight / 2;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottom),
          child: buildCoverImage(),
        ),
        Positioned(top: top, child: buildProfileImage()),
      ],
    );
  }

  Widget buildCoverImage() {
    return Container(
      height: 280,
      width: double.infinity,
      color: Colors.grey,
      child: Image.network(
        userProfileCover,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildProfileImage() {
    return CircleAvatar(
      radius: 72,
      backgroundColor: Colors.grey,
      backgroundImage: NetworkImage(userProfilePfp),
    );
  }

  Widget buildProfileInfo() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          "$firstName $lastName",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.brown[800],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            bio,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        buildFriendButton(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildFriendButton() {
    String buttonText;
    VoidCallback? onPressed;
    Color backgroundColor;
    Color textColor;

    if (isFriendRequestSent) {
      buttonText = 'Cancel Friend Request';
      backgroundColor = Colors.grey;
      textColor = Colors.white;
      onPressed = () async {
        await _databaseService.cancelFriendRequest(
            _authService.currentUser!.uid,
            widget.userId,
            updateFriendRequestStatus);
        setState(() {
          isFriend = false;
          isFriendRequestSent = false;
        });
        _alertService.showToast(
          text: "Friend request withdrawn!",
          icon: Icons.error,
        );
      };
    } else if (isFriend) {
      buttonText = 'Remove friend';
      backgroundColor = Colors.red;
      textColor = Colors.white;
      onPressed = () async {
        CustomDialog.show(
            context: context,
            title: "Remove Friend",
            content: "Do you want to remove friend?",
            cancelText: "Cancel",
            discardText: "Confirm",
            toastText: "Friend Removed",
            onDiscard: () async {
              await _databaseService.removeFriend(
                  _authService.currentUser!.uid, widget.userId);
              setState(() {
                isFriend = false;
                isFriendRequestSent = false;
              });
            });
      };
    } else {
      buttonText = 'Add friend';
      backgroundColor = Colors.blue;
      textColor = Colors.white;
      onPressed = () async {
        await _databaseService.sendFriendRequest(_authService.currentUser!.uid,
            widget.userId, updateFriendRequestStatus);
        setState(() {
          isFriendRequestSent = true;
        });
        _alertService.showToast(
          text: "Friend request sent!",
          icon: Icons.check,
        );
      };
    }

    return ElevatedButton(
      onPressed: onPressed,
      child: Text(buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor, // background color
        foregroundColor: textColor, // text color
      ),
    );
  }

  Widget buildTabBarSection() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.brown[800],
            unselectedLabelColor: Colors.brown[400],
            isScrollable: true,
            indicatorColor: Colors.brown[800], // Set the color of the tab indicator
            tabs: [
              Tab(text: 'Modules'),
              Tab(text: 'Posts'),
              Tab(text: 'Comments'),
              Tab(text: 'Mutual friends'),
            ],
          ),
          SizedBox(
            height: 400, // Adjust as needed
            child: TabBarView(
              children: [
                showModule(),
                Center(child: Text('Posts Content')),
                Center(child: Text('Comments Content')),
                showFriendsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showModule() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Current Modules:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.brown[800],
            ),
          ),
          SizedBox(height: 8),
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('users').doc(widget.userId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>;
              var currentModules = userData['currentModule'] ?? [];
              var completedModules = userData['completedModule'] ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentModules.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: currentModules.map<Widget>((module) {
                        return ListTile(
                          title: Text(
                            '$module',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.brown[700],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  if (currentModules.isEmpty)
                    Text('No current modules'),
                  const SizedBox(height: 16),
                  Text(
                    'Completed Modules:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.brown[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  if (completedModules.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: completedModules.map<Widget>((module) {
                        return ListTile(
                          title: Text(
                            '$module',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.brown[700],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  if (completedModules.isEmpty)
                    Text('No completed modules'),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget showFriendsTab() {
    return FutureBuilder<List<UserProfile?>>(
      future: _databaseService.getMutualFriends(_authService.currentUser!.uid, widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No mutual friends'));
        } else {
          return FriendListPage(friendList: snapshot.data!);
        }
      },
    );
  }

  void updateFriendRequestStatus(bool isSent) {
    setState(() {
      isFriendRequestSent = isSent;
    });
  }
}
