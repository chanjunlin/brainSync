import 'dart:io';

import 'package:brainsync/common_widgets/dialog.dart';
import 'package:brainsync/common_widgets/edit_list_field.dart';
import 'package:brainsync/common_widgets/edit_text_field.dart';
import 'package:brainsync/const.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/media_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:brainsync/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../main.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with RouteAware {
  final double coverHeight = 280;
  final double profileHeight = 144;
  final _formKey = GlobalKey<FormState>();
  final GetIt _getIt = GetIt.instance;

  List<String> getYearOptions() {
    return ["Year 1", "Year 2", "Year 3", "Year 4"];
  }

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController yearController = TextEditingController();

  File? selectedCoverImage, selectedProfileImage;
  String? userProfilePfp, userProfileCover;
  List? friendReqList;
  List<dynamic>? currentModules, completedModules;

  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late StorageService _storageService;

  late Future<void> loadedProfile;

  String? selectedYear;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _storageService = _getIt.get<StorageService>();
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
      if (userProfile != null && userProfile.exists) {
        setState(() {
          userProfileCover =
              userProfile.get('profileCoverURL') ?? PLACEHOLDER_PROFILE_COVER;
          userProfilePfp = userProfile.get('pfpURL') ?? PLACEHOLDER_PFP;
          firstNameController.text = userProfile.get('firstName') ?? 'Name';
          lastNameController.text = userProfile.get('lastName') ?? 'Name';
          selectedYear = userProfile.get("year");
          yearController.text = (selectedYear == "" ? "Year 1" : selectedYear)!;
          bioController.text = userProfile.get("bio") ?? "No bio";
          friendReqList = userProfile.get('friendReqList') ?? [];
          currentModules = userProfile.get("currentModules") ?? [];
          completedModules = userProfile.get("completedModules") ?? [];
        });
      } else {
        print('User profile not found');
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  void saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _storageService.saveData(
          coverFile: selectedCoverImage,
          profileFile: selectedProfileImage,
          uid: _authService.currentUser!.uid,
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          bio: bioController.text,
          year: yearController.text,
        );
        _alertService.showToast(
          text: "Profile updated successfully!",
          icon: Icons.check,
        );
        _navigationService.pushReplacementName("/profile");
      } catch (e) {
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
    );
  }

  Widget buildProfile() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                buildTop(),
                const SizedBox(height: 10),
                buildProfileInfo(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      height: 50,
                      child: cancelEdit(),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      height: 50,
                      child: editProfile(),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        padding: const EdgeInsets.all(16.0),
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
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    textController: firstNameController,
                    labelText: "First Name",
                    vertical: 16,
                    horizontal: 16,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextField(
                      textController: lastNameController,
                      labelText: "Last Name",
                      vertical: 16,
                      horizontal: 16,
                      maxLines: 1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              textController: bioController,
              labelText: "Bio",
              vertical: 16,
              horizontal: 16,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Year",
                filled: true,
                fillColor: Colors.transparent,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.brown,
                  ),
                ),
                labelStyle: TextStyle(
                  color: Colors.brown[800],
                ),
              ),
              value: yearController.text.isEmpty ? null : yearController.text,
              items: getYearOptions().map((year) {
                return DropdownMenuItem<String>(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  yearController.text = value!;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a year';
                }
                return null;
              },
              style: const TextStyle(color: Colors.black),
              dropdownColor: const Color(0xFFF8F9FF),
            ),
            const SizedBox(height: 16),
            const Divider(),
            CustomListField(
              modulesList: currentModules ?? [],
              moduleType: "Current",
              isEditable: true,
            ),
            const SizedBox(height: 16),
            CustomListField(
              modulesList: completedModules ?? [],
              moduleType: "Completed",
              isEditable: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget editProfile() {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.brown[300],
      ),
      onPressed: saveProfile,
      child: const Text('Save Edit'),
    );
  }

  Widget cancelEdit() {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.red[300],
      ),
      onPressed: () {
        CustomDialog.show(
            context: context,
            title: "Cancel Edit",
            content: "Do you want to cancel edit?",
            cancelText: "Cancel",
            discardText: "Confirm",
            toastText: "Stopped editing",
            onDiscard: () {
              _navigationService.pushName("/profile");
            });
      },
      child: const Text('Cancel Edit'),
    );
  }
}
