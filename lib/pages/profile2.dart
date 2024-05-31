import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:brainsync/common_widgets/bottomBar.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/media_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:brainsync/services/storage_service.dart';
import 'package:brainsync/const.dart';
import 'package:brainsync/model/user_profile.dart';
import 'edit_profile.dart';
import 'friends.dart';

class Profile2 extends StatefulWidget {
  const Profile2({super.key});

  @override
  State<Profile2> createState() => _Profile2State();
}

class _Profile2State extends State<Profile2> {
  final double coverHeight = 280;
  final double profileHeight = 144;
  final GetIt _getIt = GetIt.instance;

  int _selectedIndex = 0;
  Uint8List? pickedImage;
  File? selectedImage;
  String? userProfilePfp, userProfileCover, firstName, lastName;
  List? friendReqList;

  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late StorageService _storageService;
  late DocumentSnapshot user;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _storageService = _getIt.get<StorageService>();
    _mediaService = _getIt.get<MediaService>();
    _databaseService = _getIt.get<DatabaseService>();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          buildTop(),
          buildProfileInfo(),
          Divider(),
          buildTabBarSection(),  // Add this line
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(initialIndex: 4),
    );
  }

  Widget buildTop() {
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
        Positioned(
          top: top + profileHeight / 2 + 10,
          right: 16,
          child: buildSignOutButton(),
        ),
      ],
    );
  }

  Widget buildCoverImage() {
    return Container(
      height: coverHeight,
      width: double.infinity,
      color: Colors.grey,
      child: Image.network(
        userProfileCover ?? PLACEHOLDER_PROFILE_COVER,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildProfileImage() {
    return CircleAvatar(
      radius: profileHeight / 2,
      backgroundColor: Colors.grey,
      backgroundImage: selectedImage != null
          ? FileImage(selectedImage!)
          : NetworkImage(userProfilePfp ?? PLACEHOLDER_PFP) as ImageProvider,
    );
  }

  Widget buildSignOutButton() {
    return IconButton(
      onPressed: () async {
        bool result = await _authService.signOut();
        if (result) {
          _alertService.showToast(
            text: "Successfully logged out!",
            icon: Icons.check,
          );
          _navigationService.pushReplacementName("/login");
        }
      },
      icon: Icon(Icons.logout, color: Colors.brown[300]),
      tooltip: 'Logout',
    );
  }

  Widget buildProfileInfo() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          "${firstName ?? 'First'} ${lastName ?? 'Last'}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.brown[800],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'What Year',
          style: TextStyle(
            fontSize: 16,
            color: Colors.brown[700],
          ),
        ),
        const SizedBox(height: 16),
        editProfileButton(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildActions() {
    return Column(
      children: [
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            List<UserProfile?> friendList = await _databaseService.getFriends();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FriendListPage(friendList: friendList),
              ),
            );
          },
          child: Text("See Friends"),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget editProfileButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton.icon(
        onPressed: () {
          _alertService.showToast(
            text: "Editing profile!",
            icon: Icons.edit,
          );
          _navigationService.pushName("/editProfile");
        },
        icon: Icon(Icons.edit),
        label: Text("Edit Profile"),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          backgroundColor: Colors.brown[300],
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildFriendRequests() {
    if (friendReqList == null || friendReqList!.isEmpty) {
      return Column(
        children: [Text("No friends")],
      );
    } else {
      return Column(
        children:
        friendReqList!.map((uid) => buildFriendRequestTile(uid)).toList(),
      );
    }
  }

  Widget buildFriendRequestTile(String uid) {
    return FutureBuilder<DocumentSnapshot<Object?>>(
      future: _databaseService.getUserProfile(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('User not found');
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(userData['pfpURL']),
          ),
          title: Text(userData['firstName']),
          trailing: IconButton(
            icon: Icon(Icons.check),
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

  Widget buildTabBarSection() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.brown[800],
            unselectedLabelColor: Colors.brown[400],
            tabs: [
              Tab(text: 'Posts'),
              Tab(text: 'Comments'),
              Tab(text: 'Friends'),
            ],
          ),
          Container(
            height: 400, // Adjust as needed
            child: TabBarView(
              children: [
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

  Widget showFriendsTab() {
    return FutureBuilder<List<UserProfile?>>(
      future: _databaseService.getFriends(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No friends'));
        } else {
          // Use FriendListPage with the loaded friendList
          return FriendListPage(friendList: snapshot.data!);
        }
      },
    );
  }
}
