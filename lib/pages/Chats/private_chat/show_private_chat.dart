import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../const.dart';
import '../../../model/user_profile.dart';
import '../../../services/alert_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../../services/navigation_service.dart';
import 'chat_page.dart';

class ShowPrivateChat extends StatefulWidget {
  const ShowPrivateChat({super.key});

  @override
  State<ShowPrivateChat> createState() => _ShowPrivateChatState();
}

class _ShowPrivateChatState extends State<ShowPrivateChat> {
  final GetIt _getIt = GetIt.instance;

  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;

  late Future<void> loadedProfile;
  late Future<void> listenedToChats;

  List<String>? chats;
  String? userProfilePfp, firstName, lastName;
  StreamSubscription<DocumentSnapshot>? profileSubscription;
  StreamSubscription<QuerySnapshot>? chatsSubscription;
  Map<String, String> chatSubtitles = {};
  Map<String, Timestamp?> lastMessageTimestamps = {};

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
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
                        'No active chats',
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
                    String chatId = chats![index];
                    return FutureBuilder<DocumentSnapshot?>(
                      future: _databaseService.getChatDetails(chatId),
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
                          String chatSubtitle = chatSubtitles[chatId] ?? "";
                          List<dynamic> participantsIds =
                              chatDetails.get('participantsIds') ?? [];
                          String otherUserId = participantsIds.firstWhere(
                            (id) => id != _authService.currentUser!.uid,
                            orElse: () => '',
                          );
                          List<dynamic> participantsNames =
                              chatDetails.get('participantsNames') ?? [];
                          String otherUserName = participantsNames.firstWhere(
                            (name) =>
                                name != _authService.currentUser!.displayName,
                            orElse: () => "",
                          );
                          return FutureBuilder<DocumentSnapshot?>(
                            future: _databaseService.fetchUser(otherUserId),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox.shrink();
                              } else if (userSnapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${userSnapshot.error}'),
                                );
                              } else if (userSnapshot.hasData &&
                                  userSnapshot.data != null) {
                                UserProfile otherUser = UserProfile.fromJson(
                                  userSnapshot.data!.data()
                                      as Map<String, dynamic>,
                                );
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(
                                      otherUser.pfpURL ?? placeholderPFP,
                                    ),
                                  ),
                                  title: Text(otherUserName),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                          chatDetails
                                              .get('lastMessage')['sentAt'],
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
                                          return ChatPage(chatUser: otherUser);
                                        },
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return const Center(
                                    child: Text('User data not found'));
                              }
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

  Future<void> loadProfile() async {
    try {
      DocumentSnapshot? userProfile = await _databaseService.fetchCurrentUser();
      if (userProfile != null && userProfile.exists) {
        if (mounted) {
          setState(() {
            userProfilePfp = userProfile.get('pfpURL') ?? placeholderPFP;
            firstName = userProfile.get('firstName') ?? 'Name';
            lastName = userProfile.get('lastName') ?? 'Name';
            chats = List<String>.from(userProfile.get("chats") ?? []);
          });

          sortChatsByLatestMessage();
        }

        profileSubscription =
            userProfile.reference.snapshots().listen((updatedSnapshot) {
          if (updatedSnapshot.exists) {
            if (mounted) {
              setState(() {
                userProfilePfp =
                    updatedSnapshot.get('pfpURL') ?? placeholderPFP;
                firstName = updatedSnapshot.get('firstName') ?? 'Name';
                lastName = updatedSnapshot.get('lastName') ?? 'Name';
                chats = List<String>.from(updatedSnapshot.get("chats") ?? []);
              });
              sortChatsByLatestMessage();
            }
          }
        });
      } else {
        _alertService.showToast(
          text: 'User profile not found',
          icon: Icons.info,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> listenToChats() async {
    chatsSubscription =
        _databaseService.getAllUserChatsStream().listen((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          String chatId = doc.id;
          dynamic lastMessageData = doc.get('lastMessage');
          Timestamp? lastMessageTimestamp =
              lastMessageData != null ? lastMessageData['sentAt'] : null;
          if (lastMessageTimestamp != null) {
            if (lastMessageTimestamps[chatId] == null ||
                lastMessageTimestamps[chatId]!.compareTo(lastMessageTimestamp) <
                    0) {
              if (mounted) {
                setState(() {
                  if (chats != null && !chats!.contains(chatId)) {
                    chats!.add(chatId);
                  }
                  lastMessageTimestamps[chatId] = lastMessageTimestamp;
                });
                updateChatSubtitle(
                    chatId, lastMessageData['content'], lastMessageTimestamp);
              }
            }
          }
        }

        if (mounted) {
          sortChatsByLatestMessage();
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
    if (chats != null && lastMessageTimestamps.isNotEmpty) {
      chats!.sort((a, b) {
        Timestamp? timestampA = lastMessageTimestamps[a];
        Timestamp? timestampB = lastMessageTimestamps[b];
        if (timestampA == null && timestampB == null) {
          return 0;
        } else if (timestampA == null) {
          return 1;
        } else if (timestampB == null) {
          return -1;
        } else {
          return timestampB.compareTo(timestampA);
        }
      });
      if (mounted) {
        setState(() {
          chats = chats;
        });
      }
    }
  }

  @override
  void dispose() {
    profileSubscription?.cancel();
    chatsSubscription?.cancel();
    super.dispose();
  }
}
