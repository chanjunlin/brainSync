import 'dart:io';
import 'package:brainsync/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/media_service.dart';
import 'package:brainsync/services/storage_service.dart';
import 'package:brainsync/const.dart';

import '../model/user_profile.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final double coverHeight = 280;
  final double profileHeight = 144;
  final _formKey = GlobalKey<FormState>();
  final GetIt _getIt = GetIt.instance;
  String? userProfilePfp, userProfileCover, firstName, lastName;
  List? friendReqList;

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();

  File? selectedCoverImage, selectedProfileImage;

  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _storageService = _getIt.get<StorageService>();
    loadProfile();
  }

  void loadProfile() async {
    try {
      DocumentSnapshot? userProfile = await _databaseService.fetchUser();
      if (userProfile != null && userProfile.exists) {
        setState(() {
          userProfileCover =
              userProfile.get('profileCoverURL') ?? PLACEHOLDER_PROFILE_COVER;
          userProfilePfp = userProfile.get('pfpURL') ?? PLACEHOLDER_PFP;
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

  void saveProfile() async {
    print("hi");
    if (_formKey.currentState!.validate()) {
      try {
        String? pfpURL = userProfilePfp;
        String? profileCoverURL = userProfileCover;
        String result = await _storageService.saveData(
          coverFile: selectedCoverImage,
          profileFile: selectedProfileImage,
          uid: _authService.user!.uid,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
        );
        _alertService.showToast(
          text: "Profile updated successfully!",
          icon: Icons.check,
        );
        _navigationService.pushReplacementName("/profile");
      } catch (e) {
        print('Error saving profile: $e');
        _alertService.showToast(
          text: "Failed to update profile",
          icon: Icons.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          buildTop(),
          buildProfileInfo(),
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
        Positioned(top: top, child: buildProfileImage()),
      ],
    );
  }

  Widget buildCoverImage() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.pickImage();
        if (file != null) {
          setState(() {
            selectedCoverImage = file;
          });
        }
      },
      child: Container(
        color: Colors.grey,
        child: selectedCoverImage != null
            ? Image.file(
                selectedCoverImage!,
                height: coverHeight,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            : Image.network(
                userProfileCover ?? PLACEHOLDER_PROFILE_COVER,
                height: coverHeight,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget buildProfileImage() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.pickImage();
        if (file != null) {
          setState(() {
            selectedProfileImage = file;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Adjust the padding as needed
        child: CircleAvatar(
          radius: profileHeight / 2,
          backgroundColor: Colors.grey,
          backgroundImage: selectedProfileImage != null
              ? FileImage(selectedProfileImage!)
              : NetworkImage(userProfilePfp ?? PLACEHOLDER_PFP)
                  as ImageProvider,
        ),
      ),
    );
  }

  Widget buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Adjust the padding as needed
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveProfile,
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
