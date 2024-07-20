import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../const.dart';
import '../../services/database_service.dart';

class GroupChatDetails extends StatefulWidget {
  final String groupID;
  final String groupName;

  const GroupChatDetails({
    super.key,
    required this.groupID,
    required this.groupName,
  });

  @override
  State<GroupChatDetails> createState() => _GroupChatDetailsState();
}

class _GroupChatDetailsState extends State<GroupChatDetails> {
  final GetIt _getIt = GetIt.instance;

  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;

  late Future<void> loadedGroupChatDetails;

  late String owner;

  String? createdBy;
  String? groupID;
  String? groupName;
  Timestamp? createdAt;
  List<String> memberIDs = [];
  List<Map<String, dynamic>> members = [];

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
    loadedGroupChatDetails = loadGroupChatDetails();
  }

  Future<void> loadGroupChatDetails() async {
    try {
      DocumentSnapshot? groupChatProfile =
          await _databaseService.getGroupChatDetails(widget.groupID);
      if (groupChatProfile != null && groupChatProfile.exists) {
        var groupChatDetails = groupChatProfile.data() as Map<String, dynamic>;
        setState(() {
          createdBy = groupChatDetails['createdBy'] ?? 'Null User';
          groupID = groupChatDetails["id"] ?? widget.groupID;
          groupName = groupChatDetails["groupName"] ?? widget.groupName;
          createdAt = groupChatDetails["createdAt"];
          memberIDs =
              List<String>.from(groupChatDetails["participantsID"] ?? []);
        });

        DocumentSnapshot? ownerProfile =
            await _databaseService.fetchUser(createdBy!);
        setState(() {
          owner =
              ownerProfile?.get("firstName") + ownerProfile?.get("lastName");
        });

        for (String memberID in memberIDs) {
          DocumentSnapshot? memberSnapshot =
              await _databaseService.fetchUser(memberID);
          if (memberSnapshot != null && memberSnapshot.exists) {
            var memberData = memberSnapshot.data() as Map<String, dynamic>;
            setState(() {
              members.add(memberData);
            });
          }
        }
      } else {
        _alertService.showToast(
          text: "Group chat not found",
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
      appBar: AppBar(
        title: const Text("Group Chat Details"),
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _navigationService.goBack();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<void>(
        future: loadedGroupChatDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Error loading group chat details'));
          } else {
            return buildGroupChatDetails();
          }
        },
      ),
    );
  }

  Widget buildGroupChatDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTop(),
          const SizedBox(height: 20),
          buildProfileInfo(),
          const SizedBox(height: 20),
          buildMemberList(),
        ],
      ),
    );
  }

  Widget buildTop() {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 80,
            backgroundImage: NetworkImage(PLACEHOLDER_PFP),
          ),
          const SizedBox(height: 10),
          Text(
            widget.groupName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader("Group Info"),
        buildProfileItem(Icons.person, "Created By", owner),
        buildProfileItem(
            Icons.calendar_today,
            "Created At",
            createdAt != null
                ? DateFormat.yMMMd().format(createdAt!.toDate())
                : 'N/A'),
      ],
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

  Widget buildProfileItem(IconData icon, String title, String? value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          "$title: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          value ?? 'N/A',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget buildMemberList() {
    if (members.isEmpty) {
      return const Center(child: Text("No members found"));
    } else {
      members.sort(
        (a, b) {
          String fullNameA = (a["firstName"] ?? '') + (a["lastName"] ?? '');
          String fullNameB = (b["firstName"] ?? '') + (b["lastName"] ?? '');
          return fullNameA.compareTo(fullNameB);
        },
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
            String fullName = member["firstName"] + member["lastName"];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    NetworkImage(member['pfpURL'] ?? PLACEHOLDER_PFP),
              ),
              title: Text(fullName ?? 'No Name'),
            );
          },
        ),
      ],
    );
  }
}
