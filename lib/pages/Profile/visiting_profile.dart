import 'dart:async';

import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../common_widgets/custom_dialog.dart';
import '../../const.dart';
import '../../model/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../Chats/chat_page.dart';
import 'friends.dart';

class VisitProfile extends StatefulWidget {
  final String userId;

  const VisitProfile({super.key, required this.userId});

  @override
  State<VisitProfile> createState() => _VisitProfileState();
}

class _VisitProfileState extends State<VisitProfile> {
  bool isFriendRequestSent = false, isFriend = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;

  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;
  late StreamSubscription<DocumentSnapshot> profileStream;

  String? bio, firstName, lastName, pfpURL, profileCoverURL, uid, year;

  List<String?>? chats,
      completedModules,
      currentModules,
      friendList,
      friendReqList,
      myComments,
      myPosts,
      myLikedComments,
      myLikedPosts;

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
            bio = profile['bio'] ?? 'No bio available';
            firstName = profile['firstName'] ?? 'First';
            lastName = profile['lastName'] ?? 'Last';
            pfpURL = profile['pfpURL'] ?? PLACEHOLDER_PFP;
            profileCoverURL =
                profile['profileCoverURL'] ?? PLACEHOLDER_PROFILE_COVER;
            uid = profile['uid'];
            year = profile["year"];

            completedModules =
                List<String?>.from(profile["completedModules"] ?? []);
            currentModules =
                List<String?>.from(profile["currentModules"] ?? []);
            friendList = List<String?>.from(profile['friendList'] ?? []);
            friendReqList = List<String?>.from(profile['friendReqList'] ?? []);
            myComments = List<String?>.from(profile['myComments'] ?? []);
            myPosts = List<String?>.from(profile['myPosts'] ?? []);
            myLikedComments =
                List<String?>.from(profile['myLikedComments'] ?? []);
            myLikedPosts = List<String?>.from(profile['myLikedPosts'] ?? []);

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
      _alertService.showToast(
        text: "$e",
        icon: Icons.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        title: const Text('User Profile'),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          buildTop(),
          buildProfileInfo(),
          const Divider(),
          buildTabBarSection(),
        ],
      ),
    );
  }

  Widget buildTop() {
    const double coverHeight = 280;
    const double profileHeight = 144;
    const double bottom = profileHeight / 2;
    const double top = coverHeight - profileHeight / 2;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: bottom),
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
        profileCoverURL ?? PLACEHOLDER_PROFILE_COVER,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildProfileImage() {
    return CircleAvatar(
      radius: 72,
      backgroundColor: Colors.grey,
      backgroundImage: NetworkImage(pfpURL ?? PLACEHOLDER_PFP),
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
            bio ?? "No bio",
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
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove friend'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () async {
              final chatExists = await _databaseService.checkChatExist(
                  _authService.currentUser!.uid, widget.userId);
              if (!chatExists) {
                await _databaseService.createNewChat(
                    _authService.currentUser!.uid, widget.userId);
              }
              UserProfile? user =
                  await _databaseService.fetchUserProfile(widget.userId);
              _navigationService.push(MaterialPageRoute(builder: (context) {
                return ChatPage(chatUser: user);
              }));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[300],
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Message'),
          ),
        ],
      );
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
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor, // background color
        foregroundColor: textColor, // text color
      ),
      child: Text(buttonText),
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
            indicatorColor: Colors.brown[800],
            tabs: const [
              Tab(text: 'Modules'),
              Tab(text: 'Posts'),
              Tab(text: 'Comments'),
              Tab(text: 'Mutual friends'),
            ],
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              children: [
                showModule(),
                const Center(child: Text('Posts Content')),
                const Center(child: Text('Comments Content')),
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
          const SizedBox(height: 8),
          StreamBuilder<DocumentSnapshot>(
            stream:
                firestore.collection('users').doc(widget.userId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>;
              var currentModules = userData['currentModules'] ?? [];
              var completedModules = userData['completedModules'] ?? [];

              return Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    if (currentModules.isNotEmpty)
                      ...currentModules.map<Widget>((module) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '$module',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.brown[700],
                            ),
                          ),
                        );
                      }).toList(),
                    if (currentModules.isEmpty)
                      const Text('No current modules'),
                    const SizedBox(height: 16),
                    Text(
                      'Completed Modules:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.brown[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (completedModules.isNotEmpty)
                      ...completedModules.map<Widget>((module) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '$module',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.brown[700],
                            ),
                          ),
                        );
                      }).toList(),
                    if (completedModules.isEmpty)
                      const Text('No completed modules'),
                  ],
                ),
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
      future: _databaseService.getMutualFriends(
          _authService.currentUser!.uid, widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No mutual friends'));
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
