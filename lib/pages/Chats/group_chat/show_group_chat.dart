import 'dart:async';

import 'package:brainsync/pages/Chats/group_chat/group_chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../const.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../../services/navigation_service.dart';

class ShowGroupChat extends StatefulWidget {
  const ShowGroupChat({super.key});

  @override
  State<ShowGroupChat> createState() => _ShowGroupChatState();
}

class _ShowGroupChatState extends State<ShowGroupChat> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;

  late Future<void> loadedProfile;
  late Future<void> listenedToChats;

  List<String>? chats;
  String? groupPicture, firstName, lastName;
  StreamSubscription<DocumentSnapshot>? profileSubscription;
  StreamSubscription<QuerySnapshot>? chatsSubscription;
  Map<String, String> chatSubtitles = {};
  Map<String, Timestamp?> lastMessageTimestamps = {};

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
    loadedProfile = loadProfile();
    listenedToChats = listenToChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: chats != null
          ? chats!.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/img/meditating_brain.png"),
            const SizedBox(height: 16),
            Text(
              'No active group chats',
              style: TextStyle(
                fontSize: 20,
                color: Colors.brown[700],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: chats!.length,
        itemBuilder: (context, index) {
          String groupId = chats![index];
          return FutureBuilder<DocumentSnapshot?>(
            future: _databaseService.getGroupChatDetails(groupId),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const SizedBox.shrink();
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                DocumentSnapshot<Object?> chatDetails =
                snapshot.data!;
                String chatSubtitle = chatSubtitles[groupId] ?? "";
                String groupName = chatDetails.get("groupName");
                String groupPicture = chatDetails.get("groupPicture") ?? PLACEHOLDER_PFP;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(groupPicture,
                    ),
                  ),
                  title: Text(groupName),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chatSubtitle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Text(
                        getFormattedTime(
                          chatDetails.get('lastMessage')?['sentAt'],
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    _navigationService.push(
                      MaterialPageRoute(
                        builder: (context) {
                          return GroupChatPage(
                            groupID: groupId,
                            groupName: groupName,
                          );
                        },
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                    child: Text('Chat details not found'));
              }
            },
          );
        },
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> loadProfile() async {
    try {
      DocumentSnapshot? userProfile = await _databaseService.fetchCurrentUser();
      if (userProfile != null && userProfile.exists) {
        if (mounted) {
          setState(() {
            firstName = userProfile.get('firstName') ?? 'Name';
            lastName = userProfile.get('lastName') ?? 'Name';
            chats = List<String>.from(userProfile.get("groupChats") ?? []);
          });

          sortChatsByLatestMessage();
        }

        profileSubscription =
            userProfile.reference.snapshots().listen((updatedSnapshot) {
              if (updatedSnapshot.exists) {
                if (mounted) {
                  setState(() {
                    firstName = updatedSnapshot.get('firstName') ?? 'Name';
                    lastName = updatedSnapshot.get('lastName') ?? 'Name';
                    chats =
                    List<String>.from(updatedSnapshot.get("groupChats") ?? []);
                  });
                  sortChatsByLatestMessage();
                }
              }
            });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> listenToChats() async {
    chatsSubscription =
        _databaseService.getAllUserGroupChatsStream().listen((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            if (mounted) {
              setState(() {
                for (var doc in querySnapshot.docs) {
                  String groupChatId = doc.id;
                  dynamic lastMessageData = doc.get('lastMessage');
                  Timestamp? lastMessageTimestamp =
                  lastMessageData != null ? lastMessageData['sentAt'] : null;
                  if (lastMessageTimestamp != null) {
                    if (lastMessageTimestamps[groupChatId] == null ||
                        lastMessageTimestamps[groupChatId]!
                            .compareTo(lastMessageTimestamp) <
                            0) {
                      chats!.remove(groupChatId);
                      chats!.add(groupChatId);
                      lastMessageTimestamps[groupChatId] = lastMessageTimestamp;
                      updateChatSubtitle(groupChatId, lastMessageData['content'],
                          lastMessageTimestamp);
                    }
                  }
                }

                sortChatsByLatestMessage();
              });
            }
          } else {
            if (mounted) {
              setState(() {
                chats = [];
              });
            }
          }
        });
  }

  String getFormattedTime(Timestamp? timestamp) {
    if (timestamp != null) {
      final now = DateTime.now();
      final difference = now.difference(timestamp.toDate());
      if (difference.inDays > 0) {
        return DateFormat.yMMMd().format(timestamp.toDate());
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'just now';
      }
    }
    return '';
  }

  void updateChatSubtitle(String groupID, String content, Timestamp? sentAt) {
    if (sentAt != null) {
      final now = DateTime.now();
      final difference = now.difference(sentAt.toDate());
      String subtitle = '';
      if (difference.inDays > 0) {
        subtitle = DateFormat.yMMMd().format(sentAt.toDate());
      } else if (difference.inHours > 0) {
        subtitle = '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        subtitle = '${difference.inMinutes}m ago';
      } else {
        subtitle = 'just now';
      }

      if (mounted) {
        setState(() {
          chatSubtitles[groupID] = content;
        });
      }
    }
  }

  void sortChatsByLatestMessage() {
    if (chats != null && chats!.isNotEmpty) {
      chats!.sort((a, b) {
        Timestamp? aTimestamp = lastMessageTimestamps[a];
        Timestamp? bTimestamp = lastMessageTimestamps[b];
        if (aTimestamp == null || bTimestamp == null) return 0;
        return bTimestamp.compareTo(aTimestamp);
      });
    }
  }

  @override
  void dispose() {
    profileSubscription?.cancel();
    chatsSubscription?.cancel();
    super.dispose();
  }
}
