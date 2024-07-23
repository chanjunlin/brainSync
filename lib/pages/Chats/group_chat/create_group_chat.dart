import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../const.dart';
import '../../../model/user_profile.dart';
import '../../../services/alert_service.dart';
import '../../../services/database_service.dart';
import '../../../services/navigation_service.dart';
import 'group_chat_page.dart';

class GroupChatCreation extends StatefulWidget {
  const GroupChatCreation({super.key});

  @override
  GroupChatCreationState createState() => GroupChatCreationState();
}

class GroupChatCreationState extends State<GroupChatCreation> {
  final GetIt _getIt = GetIt.instance;
  final TextEditingController groupNameController = TextEditingController();

  late AlertService _alertService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;

  List<UserProfile?> _friends = [];
  List<UserProfile?> selectedFriends = [];

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
    loadFriends();
  }

  Future<void> loadFriends() async {
    try {
      _friends = await _databaseService.getFriends();
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

  void createGroupChat() async {
    String groupName = groupNameController.text.trim();
    if (groupName.isEmpty) {
      _alertService.showToast(
        text: "Please enter a group name",
        icon: Icons.info,
      );
    } else if (selectedFriends.isEmpty) {
      _alertService.showToast(
        text: "Please select at least 1 friend",
        icon: Icons.info,
      );
    }
    String groupId = const Uuid().v4();
    try {
      await _databaseService.createNewGroup(
          groupId, groupName, selectedFriends);
      Navigator.pop(context);
      _navigationService.push(
        MaterialPageRoute(
          builder: (context) {
            return GroupChatPage(groupID: groupId, groupName: groupName);
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error => ${e}");
      }
      _alertService.showToast(
        text: "Error creating group",
        icon: Icons.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Group Chat'),
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
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
                          NetworkImage(friend.pfpURL ?? PLACEHOLDER_PFP),
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
              onPressed: createGroupChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[300],
              ),
              child: const Text(
                'Create Group Chat',
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
