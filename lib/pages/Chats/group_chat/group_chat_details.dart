import 'package:brainsync/common_widgets/custom_read_only.dart';
import 'package:brainsync/pages/Chats/group_chat/add_people_to_group_chat.dart';
import 'package:brainsync/pages/Chats/group_chat/edit_group_chat_details.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../common_widgets/chat_tile.dart';
import '../../../common_widgets/custom_dialog.dart';
import '../../../const.dart';
import '../../../services/database_service.dart';
import '../../Profile/visiting_profile/visiting_profile.dart';
import '../friends_chat.dart';
import 'group_chat_page.dart';

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
  late String groupDescription;

  String? createdBy;
  String? groupID;
  String? groupName;
  String? groupPicture;

  Timestamp? createdAt;
  List<String> adminIDs = [];
  List<String> memberIDs = [];
  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> admins = [];

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
          groupName = groupChatDetails["groupName"] ?? "Null Group";
          groupPicture = groupChatDetails["groupPicture"] ?? PLACEHOLDER_PFP;
          createdAt = groupChatDetails["createdAt"];
          adminIDs = List<String>.from(groupChatDetails["admins"] ?? []);
          memberIDs =
              List<String>.from(groupChatDetails["participantsID"] ?? []);
          groupDescription = groupChatDetails["groupDescription"] ??
              'No description available';
        });

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
          owner = ownerProfile?.get("firstName") +
              " " +
              ownerProfile?.get("lastName");
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
        icon: Icons.error,
      );
      if (kDebugMode) {
        print("Error => $e");
      }
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
            _navigationService.push(
              MaterialPageRoute(
                builder: (context) {
                  return GroupChatPage(
                    groupID: groupID!,
                    groupName: groupName!,
                  );
                },
              ),
            );
          },
        ),
        actions: [
          extraActions(),
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
          buildGroupDescription(),
          buildAdminList(),
          buildMemberList(),
          const SizedBox(height: 10),
          buildGroupInfo(),
        ],
      ),
    );
  }

  Widget buildTop() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 80,
            backgroundImage: NetworkImage(groupPicture!),
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

  Widget buildGroupDescription() {
    return CustomReadOnlyField(
      labelText: "Group Description",
      hintText: groupDescription,
      height: 70,
      text: groupDescription,
    );
  }

  Widget buildMemberList() {
    members.sort((a, b) {
      String fullNameA = (a["firstName"] ?? '') + (a["lastName"] ?? '');
      String fullNameB = (b["firstName"] ?? '') + (b["lastName"] ?? '');
      return fullNameA.compareTo(fullNameB);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader("Members"),
        if (members.isEmpty) ...[
          const Text("No members found"),
          Center(
            child: TextButton.icon(
              onPressed: addPeople,
              icon: const Icon(Icons.person_add),
              label: const Text("Add People"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.brown[300],
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              itemBuilder: (context, index) {
                var member = members[index];
                String fullName =
                    (member["firstName"] ?? '') + (member["lastName"] ?? '');
                String displayName =
                    member["uid"] == _authService.currentUser!.uid
                        ? "Me"
                        : fullName;
                return CustomChatTile(
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
                );
              },
            ),
          ),
          Center(
            child: TextButton.icon(
              onPressed: addPeople,
              icon: const Icon(Icons.person_add),
              label: const Text("Add People"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.brown[300],
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
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
        buildSectionHeader("Admins"),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: admins.length,
          itemBuilder: (context, index) {
            var admin = admins[index];
            String fullName =
                (admin["firstName"] ?? '') + (admin["lastName"] ?? '');
            String displayName =
                admin["uid"] == _authService.currentUser!.uid ? "Me" : fullName;

            return Stack(
              children: [
                CustomChatTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        admin['profilePictureUrl'] ?? PLACEHOLDER_PFP),
                  ),
                  title: displayName,
                  subtitle: admin["bio"] ?? 'No bio available',
                  onTap: () {
                    _navigationService.push(
                      MaterialPageRoute(
                        builder: (context) {
                          return VisitProfile(
                            userId: admin['uid'] as String,
                          );
                        },
                      ),
                    );
                  },
                ),
                if (admin["uid"] == createdBy)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      color: Colors.grey.withOpacity(0.2),
                      child: const Text(
                        "Owner",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget buildGroupInfo() {
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

  Widget extraActions() {
    if (_authService.currentUser!.uid == createdBy) {
      return Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              _navigationService.push(
                MaterialPageRoute(
                  builder: (context) => EditGroupChatDetails(
                    groupID: widget.groupID,
                    groupName: widget.groupName,
                  ),
                ),
              );
            },
          ),
        ],
      );
    } else {
      if (adminIDs.contains(_authService.currentUser!.uid)) {
        return Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                _navigationService.push(
                  MaterialPageRoute(
                    builder: (context) => EditGroupChatDetails(
                      groupID: widget.groupID,
                      groupName: widget.groupName,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                exitGroup();
              },
            ),
          ],
        );
      } else {
        return IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            exitGroup();
          },
        );
      }
    }
  }

  void addPeople() {
    _navigationService.push(
      MaterialPageRoute(
        builder: (context) {
          return AddPeople(
            groupID: widget.groupID,
            groupName: widget.groupName,
          );
        },
      ),
    );
  }

  void exitGroup() async {
    CustomDialog.show(
      context: context,
      title: "Leave group",
      content: "Do you want to leave group?",
      cancelText: "Cancel",
      discardText: "Confirm",
      toastText: "Group left",
      onDiscard: () {
        _databaseService.leaveGroupChat(
          widget.groupID,
          _authService.currentUser!.uid,
        );
        _navigationService.pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return const FriendsChats(tabNumber: 1);
            },
          ),
        );
      },
    );
  }
}
