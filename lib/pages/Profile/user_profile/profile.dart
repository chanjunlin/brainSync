import 'dart:io';
import 'dart:typed_data';

import 'package:brainsync/const.dart';
import 'package:brainsync/pages/Profile/user_profile/show_my_friends.dart';
import 'package:brainsync/pages/Profile/user_profile/show_my_modules.dart';
import 'package:brainsync/pages/Profile/user_profile/show_my_posts.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../common_widgets/bottomBar.dart';
import '../../../main.dart';

class Profile extends StatefulWidget {
  final ImageProvider? profileImageProvider;
  final ImageProvider? coverImageProvider;

  const Profile({
    Key? key,
    this.profileImageProvider,
    this.coverImageProvider,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with RouteAware {
  final double coverHeight = 280;
  final double profileHeight = 144;
  final GetIt _getIt = GetIt.instance;

  Uint8List? pickedImage;
  File? selectedImage;

  int? currentCredits;

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

  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;
  late DocumentSnapshot user;

  late Future<void> loadedProfile;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    loadedProfile = loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(
        this as RouteAware, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this as RouteAware);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      loadedProfile = loadProfile();
    });
  }

  Future<void> loadProfile() async {
    try {
      DocumentSnapshot? userProfile = await _databaseService.fetchCurrentUser();
      if (userProfile!.exists) {
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
          currentModules = List<String?>.from(profile["currentModules"] ?? []);
          currentCredits = profile['currentCredits'] ?? 0;
          friendList = List<String?>.from(profile['friendList'] ?? []);
          friendReqList = List<String?>.from(profile['friendReqList'] ?? []);
          myComments = List<String?>.from(profile['myComments'] ?? []);
          myPosts = List<String?>.from(profile['myPosts'] ?? []);
          myLikedComments =
              List<String?>.from(profile['myLikedComments'] ?? []);
          myLikedPosts = List<String?>.from(profile['myLikedPosts'] ?? []);
          friendReqList!.contains(_authService.currentUser!.uid);
        });
      } else {
        _alertService.showToast(
          text: "User profile not found",
          icon: Icons.error,
        );
      }
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
      body: FutureBuilder<void>(
        future: loadedProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading profile'));
          } else {
            return buildProfile();
          }
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 4),
    );
  }

  Widget buildProfile() {
    return Scaffold(
      backgroundColor: Colors.white,
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
        Positioned(
          top: top,
          child: buildProfileImage(),
        ),
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
    child: Image(
      image: widget.coverImageProvider ?? NetworkImage(profileCoverURL ?? PLACEHOLDER_PROFILE_COVER),
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
        : (widget.profileImageProvider ?? NetworkImage(pfpURL ?? PLACEHOLDER_PFP)),
  );
}

  Widget buildSignOutButton() {
    return IconButton(
      onPressed: () async {
        await _authService.signOut();
        _alertService.showToast(
          text: "Successfully logged out!",
          icon: Icons.check,
        );
        _navigationService.pushReplacementName("/login");
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
        const SizedBox(height: 16),
        Text(
          '$bio',
          style: TextStyle(
            fontSize: 20,
            color: Colors.brown[800],
          ),
        ),
        const SizedBox(height: 16),
        editProfileButton(),
        const SizedBox(height: 16),
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
        icon: const Icon(Icons.edit),
        label: const Text("Edit Profile"),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.brown[300],
          foregroundColor: Colors.white,
        ),
      ),
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
              Tab(text: 'Friends'),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: TabBarView(
              children: [
                showModule(),
                showPost(),
                showFriends(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showModule() {
    return ShowModule(
      currentModules: currentModules,
      completedModules: completedModules,
    );
  }

  Widget showPost() {
    return ShowMyPosts(myPosts: myPosts);
  }

  Widget showFriends() {
    return const ShowMyFriends();
  }
}
