import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../const.dart';
import '../../../model/user_profile.dart';
import '../../../services/alert_service.dart';
import '../../../services/database_service.dart';
import '../../../services/navigation_service.dart';
import 'group_chat_details.dart';

class AddPeople extends StatefulWidget {
  final String groupID;
  final String groupName;

  const AddPeople({super.key, required this.groupID, required this.groupName});

  @override
  AddPeopleState createState() => AddPeopleState();
}

class AddPeopleState extends State<AddPeople> {
  final GetIt _getIt = GetIt.instance;
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupDescriptionController = TextEditingController();

  late AlertService _alertService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;
  late Future<void> loadedGroupChatDetails;

  late String owner;
  late String groupDescription;

  String? createdBy;
  String? groupID;
  String? groupName;
  String? groupPicture;

  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> admins = [];
  List<String> adminIDs = [];
  List<String> memberIDs = [];

  Timestamp? createdAt;

  List<UserProfile?> _friends = [];
  List<UserProfile?> selectedFriends = [];

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
    loadGroupChatDetails();
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
            groupPicture = groupChatDetails["groupPicture"] ?? placeholderPFP;
            createdAt = groupChatDetails["createdAt"];
            adminIDs = List<String>.from(groupChatDetails["admins"] ?? []);
            memberIDs = List<String>.from(groupChatDetails["participantsID"] ?? []);
            groupDescriptionController.text = groupChatDetails["groupDescription"] ?? 'No description available';
            groupNameController.text = groupChatDetails["groupName"] ?? "No name";
          },
        );

        DocumentSnapshot? ownerProfile =
        await _databaseService.fetchUser(createdBy!);
        setState(() {
          owner =
              ownerProfile?.get("firstName") + ownerProfile?.get("lastName");
        });
        loadFriends();
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

  Future<void> loadFriends() async {
    try {
      List<UserProfile?> allFriends = await _databaseService.getFriends();
      _friends = allFriends.where((friend) => !memberIDs.contains(friend!.uid)).toList();
      setState(() {});
    } catch (e) {
      _alertService.showToast(text: "Error loading friends");
    }
  }

  void toggleSelection(UserProfile friend) {
    setState(() {
      if (selectedFriends.contains(friend)) {
        selectedFriends.remove(friend);
      } else {
        selectedFriends.add(friend);
      }
    });
  }

  void addFriends() async {
    if (selectedFriends.isEmpty) {
      _alertService.showToast(
        text: "Please select at least 1 friend",
        icon: Icons.info,
      );
    } else {
      try {
        await _databaseService.addFriend(widget.groupID, selectedFriends);
        Navigator.pop(context);
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
        if (kDebugMode) {
          print("Error => $e");
        }
        _alertService.showToast(
          text: "Error creating group",
          icon: Icons.info,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add People to Group Chat'),
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _friends.isEmpty
                  ? const Center(
                child: Text('No friends available', style: TextStyle(fontSize: 18, color: Colors.grey)),
              )
                  : ListView.builder(
                itemCount: _friends.length,
                itemBuilder: (context, index) {
                  UserProfile? friend = _friends[index];
                  if (friend == null) {
                    return const SizedBox.shrink();
                  }
                  return ListTile(
                    title: Text("${friend.firstName} ${friend.lastName}"),
                    leading: CircleAvatar(
                      backgroundImage:
                      NetworkImage(friend.pfpURL ?? placeholderPFP),
                    ),
                    trailing: Checkbox(
                      value: selectedFriends.contains(friend),
                      onChanged: (isSelected) {
                        if (isSelected != null) {
                          toggleSelection(friend);
                        }
                      },
                    ),
                    onTap: () => toggleSelection(friend),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: addFriends,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[300],
              ),
              child: const Text(
                'Add selected friend(s)',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
