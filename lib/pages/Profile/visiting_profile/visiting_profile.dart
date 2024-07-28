import 'dart:async';

import 'package:brainsync/pages/Profile/user_profile/show_my_posts.dart';
import 'package:brainsync/pages/Profile/visiting_profile/show_friends.dart';
import 'package:brainsync/pages/Profile/visiting_profile/show_modules.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../common_widgets/custom_dialog.dart';
import '../../../const.dart';
import '../../../model/user_profile.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../Chats/private_chat/chat_page.dart';

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
            pfpURL = profile['pfpURL'] ?? placeholderPFP;
            profileCoverURL =
                profile['profileCoverURL'] ?? placeholderProfileCover;
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
      backgroundColor: Colors.white,
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
        profileCoverURL ?? placeholderProfileCover,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildProfileImage() {
    return CircleAvatar(
      radius: 72,
      backgroundColor: Colors.grey,
      backgroundImage: NetworkImage(pfpURL ?? placeholderPFP),
    );
  }

  Widget buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        children: [
          Text(
            "$firstName $lastName",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.brown[800],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            bio ?? "No bio",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          buildFriendButton(),
          const SizedBox(height: 16),
        ],
      ),
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
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
      ),
      child: Text(buttonText),
    );
  }

  Widget buildTabBarSection() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.brown[800],
            unselectedLabelColor: Colors.brown[400],
            tabs: const [
              Tab(text: 'Modules'),
              Tab(text: 'Posts'),
              Tab(text: 'Mutual Friends'),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: TabBarView(
              children: [
                showModule(widget.userId),
                showPosts(),
                showFriends(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showModule(String userID) {
    return ShowUserModules(
      userID: userID,
    );
  }

  Widget showPosts() {
    return ShowMyPosts(myPosts: myPosts);
  }

  Widget showFriends() {
    return ShowUserFriends(userID: widget.userId);
  }

  void updateFriendRequestStatus(bool isSent) {
    setState(() {
      isFriendRequestSent = isSent;
    });
  }
}
