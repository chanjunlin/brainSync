import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../model/user_profile.dart';
import '../../services/database_service.dart';
import '../../services/navigation_service.dart';
import 'group_chat_page.dart';

class GroupChatCreation extends StatefulWidget {
  @override
  _GroupChatCreationState createState() => _GroupChatCreationState();
}

class _GroupChatCreationState extends State<GroupChatCreation> {
  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;

  final TextEditingController groupNameController = TextEditingController();
  List<UserProfile?> _friends = [];
  List<UserProfile?> selectedFriends = [];

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      _friends = await _databaseService.getFriends();
      setState(() {});
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading friends: $e')),
      );
    }
  }

  void _toggleSelection(UserProfile friend) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group name'),
        ),
      );
      return;
    } else if (selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select friends'),
        ),
      );
      return;
    }
    String groupId = Uuid().v4();
    try {
      await _databaseService.createNewGroup(groupId, groupName, selectedFriends);
      Navigator.pop(context);
      _navigationService.push(MaterialPageRoute(builder: (context) {
        return GroupChatPage(groupID: groupId, groupName: groupName);
      }));
    } catch (e) {
      // Handle errors
      print("ASD?");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  if (friend == null)
                    return SizedBox.shrink(); // Handle null case

                  return ListTile(
                    title: Text("${friend.firstName} ${friend.lastName}"),
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(friend.pfpURL ?? 'PLACEHOLDER_URL'),
                    ),
                    trailing: Checkbox(
                      value: selectedFriends.contains(friend),
                      onChanged: (isSelected) {
                        if (isSelected != null) {
                          _toggleSelection(friend);
                        }
                      },
                    ),
                    onTap: () => _toggleSelection(friend),
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
              child: const Text('Create Group Chat', style: TextStyle(
                color: Colors.white,
              ),),
            ),
          ],
        ),
      ),
    );
  }
}
