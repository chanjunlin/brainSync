import 'dart:io';

import 'package:brainsync/common_widgets/edit_text_field.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../common_widgets/chat_tile.dart';
import '../../../common_widgets/custom_dialog.dart';
import '../../../const.dart';
import '../../../main.dart';
import '../../../services/database_service.dart';
import '../../../services/media_service.dart';
import '../../../services/storage_service.dart';
import '../../Profile/visiting_profile/visiting_profile.dart';
import 'group_chat_details.dart';

class EditGroupChatDetails extends StatefulWidget {
  final String groupID;
  final String groupName;

  const EditGroupChatDetails({
    super.key,
    required this.groupID,
    required this.groupName,
  });

  @override
  State<EditGroupChatDetails> createState() => _EditGroupChatDetailsState();
}

class _EditGroupChatDetailsState extends State<EditGroupChatDetails>
    with RouteAware {
  final _formKey = GlobalKey<FormState>();
  final double coverHeight = 280;
  final GetIt _getIt = GetIt.instance;
  final TextEditingController groupDescriptionController =
      TextEditingController();
  final TextEditingController groupNameController = TextEditingController();

  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late StorageService _storageService;
  late Future<void> loadedGroupChatDetails;

  late String owner;
  late String groupDescription;

  File? selectedGroupPicture;

  String? createdBy;
  String? groupID;
  String? groupName;
  String? groupPicture;

  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> admins = [];
  List<String> adminIDs = [];
  List<String> memberIDs = [];

  Timestamp? createdAt;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _storageService = _getIt.get<StorageService>();
    loadedGroupChatDetails = loadGroupChatDetails();
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
      loadedGroupChatDetails = loadGroupChatDetails();
    });
  }

  Future<void> loadGroupChatDetails() async {
    try {
      DocumentSnapshot? groupChatProfile =
          await _databaseService.getGroupChatDetails(widget.groupID);
      if (groupChatProfile != null && groupChatProfile.exists) {
        var groupChatDetails = groupChatProfile.data() as Map<String, dynamic>;
        setState(
          () {
            createdBy = groupChatDetails['createdBy'] ?? 'Null User';
            groupID = groupChatDetails["id"] ?? widget.groupID;
            groupName = groupChatDetails["groupName"] ?? "Null Group";
            groupPicture = groupChatDetails["groupPicture"] ?? PLACEHOLDER_PFP;
            createdAt = groupChatDetails["createdAt"];
            adminIDs = List<String>.from(groupChatDetails["admins"] ?? []);
            memberIDs =
                List<String>.from(groupChatDetails["participantsID"] ?? []);
            groupDescriptionController.text =
                groupChatDetails["groupDescription"] ??
                    'No description available';
            groupNameController.text =
                groupChatDetails["groupName"] ?? "No name";
          },
        );

        for (String adminID in adminIDs) {
          DocumentSnapshot? memberSnapshot =
              await _databaseService.fetchUser(adminID);
          if (memberSnapshot != null && memberSnapshot.exists) {
            var memberData = memberSnapshot.data() as Map<String, dynamic>;
            setState(() {
              admins.add(memberData);
            });
          }
        }
        for (String memberID in memberIDs) {
          DocumentSnapshot? memberSnapshot =
              await _databaseService.fetchUser(memberID);
          if (memberSnapshot != null && memberSnapshot.exists) {
            if (!adminIDs.contains(memberID)) {
              var memberData = memberSnapshot.data() as Map<String, dynamic>;
              setState(() {
                members.add(memberData);
              });
            }
          }
        }
        DocumentSnapshot? ownerProfile =
            await _databaseService.fetchUser(createdBy!);
        setState(() {
          owner =
              ownerProfile?.get("firstName") + ownerProfile?.get("lastName");
        });
      } else {
        _alertService.showToast(
          text: 'User profile not found',
          icon: Icons.info,
        );
      }
    } catch (e) {
      _alertService.showToast(
        text: 'Error loading profile',
        icon: Icons.info,
      );
      if (kDebugMode) {
        print('Error => $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Group Chat Details"),
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTop(),
              const SizedBox(height: 20),
              buildGroupDescription(),
              const SizedBox(height: 20),
              buildAdminList(),
              buildMemberList(),
              buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTop() {
    return Center(
      child: Column(
        children: [
          buildGroupImage(),
          const SizedBox(height: 10),
          CustomTextField(
            textController: groupNameController,
            maxLines: 1,
            labelText: 'Group name',
            vertical: 16,
            horizontal: 16,
          ),
        ],
      ),
    );
  }

  Widget buildGroupImage() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.pickImage();
        if (file != null) {
          setState(() {
            selectedGroupPicture = file;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CircleAvatar(
          radius: 80,
          backgroundColor: Colors.brown[300],
          backgroundImage: selectedGroupPicture != null
              ? FileImage(selectedGroupPicture!)
              : NetworkImage(groupPicture ?? PLACEHOLDER_PFP) as ImageProvider,
        ),
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget buildGroupDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          textController: groupDescriptionController,
          labelText: 'Group description',
          maxLines: 3,
          vertical: 16,
          horizontal: 16,
        ),
      ],
    );
  }

  Widget buildMemberList() {
    members.sort((a, b) {
      String fullNameA = (a["firstName"] ?? '') + (a["lastName"] ?? '');
      String fullNameB = (b["firstName"] ?? '') + (b["lastName"] ?? '');
      return fullNameA.compareTo(fullNameB);
    });

    if (members.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader("Members"),
          const Text("No members found"),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader("Members"),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          itemBuilder: (context, index) {
            var member = members[index];
            String fullName =
                (member["firstName"] ?? '') + (member["lastName"] ?? '');
            bool isAdmin = adminIDs.contains(member["uid"]);
            String displayName = member["uid"] == _authService.currentUser!.uid
                ? "Me"
                : fullName;
            return Row(
              children: [
                Expanded(
                  child: CustomChatTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                          member['profilePictureUrl'] ?? PLACEHOLDER_PFP),
                    ),
                    title: displayName,
                    subtitle: member["bio"] ?? 'No bio available',
                    onTap: () {
                      _navigationService.push(
                        MaterialPageRoute(
                          builder: (context) {
                            return VisitProfile(
                              userId: member['uid'] as String,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Checkbox(
                    value: isAdmin,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          if (!adminIDs.contains(member["uid"])) {
                            adminIDs.add(member["uid"]);
                          }
                        } else {
                          adminIDs.remove(member["uid"]);
                        }
                      });
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget buildAdminList() {
    admins.sort((a, b) {
      String fullNameA = (a["firstName"] ?? '') + (a["lastName"] ?? '');
      String fullNameB = (b["firstName"] ?? '') + (b["lastName"] ?? '');
      return fullNameA.compareTo(fullNameB);
    });

    if (admins.isEmpty) {
      return const Center(child: Text("No admins found"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildSectionHeader("Admins"),
            const Text(
              'Make admin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: admins.length,
          itemBuilder: (context, index) {
            var member = admins[index];
            String fullName =
                (member["firstName"] ?? '') + (member["lastName"] ?? '');
            bool isAdmin = adminIDs.contains(member["uid"]);
            bool isCreator = member["uid"] == createdBy;
            String displayName = member["uid"] == _authService.currentUser!.uid
                ? "Me"
                : fullName;

            return Row(
              children: [
                Expanded(
                  child: CustomChatTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                          member['profilePictureUrl'] ?? PLACEHOLDER_PFP),
                    ),
                    title: displayName,
                    subtitle: member["bio"] ?? 'No bio available',
                    onTap: () {
                      _navigationService.push(
                        MaterialPageRoute(
                          builder: (context) {
                            return VisitProfile(
                              userId: member['uid'] as String,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (!isCreator)
                  SizedBox(
                    width: 80,
                    child: Checkbox(
                      value: isAdmin,
                      onChanged: (bool? value) {
                        setState(
                          () {
                            if (value == true) {
                              if (!adminIDs.contains(member["uid"])) {
                                adminIDs.add(member["uid"]);
                              }
                            } else {
                              adminIDs.remove(member["uid"]);
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget buildButtons() {
    return Padding(
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
                child: saveDetails(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget saveDetails() {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.brown[300],
      ),
      onPressed: saveGroupChatDetails,
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
            _navigationService.pushReplacement(
              MaterialPageRoute(
                builder: (context) {
                  return GroupChatDetails(
                    groupID: widget.groupID,
                    groupName: widget.groupName,
                  );
                },
              ),
            );
          },
        );
      },
      child: const Text('Cancel Edit'),
    );
  }

  void saveGroupChatDetails() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _storageService.saveGroupChatData(
          groupPictureFile: selectedGroupPicture,
          groupDescription: groupDescriptionController.text,
          groupName: groupNameController.text,
          groupID: widget.groupID,
          adminList: adminIDs,
        );
        _alertService.showToast(
          text: "Group details updated successfully!",
          icon: Icons.check,
        );
        _navigationService.pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return GroupChatDetails(
                groupID: widget.groupID,
                groupName: widget.groupName,
              );
            },
          ),
        );
      } catch (e) {
        _alertService.showToast(
          text: "Failed to update profile",
          icon: Icons.error,
        );
      }
    }
  }
}
