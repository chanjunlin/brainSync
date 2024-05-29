import 'dart:io';
import 'dart:typed_data';

import 'package:brainsync/common_widgets/bottomBar.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/media_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../const.dart';
import '../model/user_profile.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../services/storage_service.dart';
import 'friends.dart';
import 'post.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GetIt _getIt = GetIt.instance;

  int _selectedIndex = 0;
  Uint8List? pickedImage;
  File? selectedImage;
  String? userProfilePfp, name;
  List? friendReqList;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late MediaService _mediaService;
  late StorageService _storageService;
  late DatabaseService _databaseService;

  final double coverHeight = 280;
  final double profileHeight = 144;

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
          buildContent(),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 20,
          ),
          child: GNav(
            backgroundColor: Colors.black,
            tabBackgroundColor: Colors.grey,
            color: Colors.white,
            activeColor: Colors.white,
            gap: 8,
            tabs: [
              GButton(
                icon: Icons.home,
                text: "Home",
                onPressed: () async {
                  _navigationService.pushName("/home");
                },
              ),
              GButton(
                icon: Icons.chat,
                text: "Chats",
                onPressed: () async {
                  _navigationService.pushName("/chat");
                },
              ),
              GButton(
                icon: Icons.add,
                text: "Create",
                onPressed: () async {
                  _navigationService.pushName("/post");
                },
              ),
              GButton(
                icon: Icons.person_2,
                text: "Profile",
              ),
            ],
            selectedIndex: 3,
            onTabChange: (index) {
              print(index);
            },
          ),
        ),
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
            margin: EdgeInsets.only(
              bottom: bottom,
            ),
            child: buildCoverImage()),
        Positioned(top: top, child: buildProfileImage()),
      ],
    );
  }

  Widget buildCoverImage() {
    return Container(
      color: Colors.grey,
      child: Image.network(
        'https://www.comp.nus.edu.sg/~ngne/WEFiles/Image/Gallery/ee8928e7-a052-4ad9-9e41-be48898249fa/c835da5a-2.jpg',
        height: coverHeight,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildProfileImage() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.pickImage();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(userProfilePfp ?? PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  Widget buildContent() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: "Name: "),
              TextSpan(text: "${name}"),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text('What Year'),
        const SizedBox(height: 10),
        Divider(),
        const SizedBox(height: 16),
        IconButton(
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
          icon: Icon(Icons.logout),
        ),
        const SizedBox(height: 16),
        IconButton(
          onPressed: () async {
            String? pfpURl = await _storageService.saveData(
              file: selectedImage!,
              uid: _authService.user!.uid,
            );
            print("saved");
          },
          icon: Icon(Icons.save_alt),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            List<UserProfile?> friendList = await _databaseService.getFriends();
            // Navigate to a new page and pass the friendList
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FriendListPage(friendList: friendList),
              ),
            );
          },
          child: Text("See"),
        ),
        const SizedBox(height: 10),
        buildFriendReqSection(),
      ],
    );
  }

  Widget buildFriendReqSection() {
    if (friendReqList == null) {
      return Container();
    }
    return Column(
      children:
          friendReqList!.map((uid) => buildFriendRequestTile(uid)).toList(),
    );
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
      DocumentSnapshot? userProfile = await _databaseService.fetchUser();
      if (userProfile != null && userProfile.exists) {
        setState(() {
          userProfilePfp = userProfile.get('pfpURL') ?? PLACEHOLDER_PFP;
          name = userProfile.get('firstName') ?? 'Name'; // Example field
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
