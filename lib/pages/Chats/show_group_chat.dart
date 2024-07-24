import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../const.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/navigation_service.dart';

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
  String? userProfilePfp, firstName, lastName;
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
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
    );
  }

  Future<void> loadProfile() async {
    try {
      DocumentSnapshot? userProfile = await _databaseService.fetchCurrentUser();
      if (userProfile != null && userProfile.exists) {
        setState(() {
          userProfilePfp = userProfile.get('pfpURL') ?? PLACEHOLDER_PFP;
          firstName = userProfile.get('firstName') ?? 'Name';
          lastName = userProfile.get('lastName') ?? 'Name';
          chats = List<String>.from(userProfile.get("chats") ?? []);
        });

        sortChatsByLatestMessage(); // Sort chats initially

        // Listen to profile updates
        profileSubscription =
            userProfile.reference.snapshots().listen((updatedSnapshot) {
              if (updatedSnapshot.exists) {
                setState(() {
                  userProfilePfp = updatedSnapshot.get('pfpURL') ?? PLACEHOLDER_PFP;
                  firstName = updatedSnapshot.get('firstName') ?? 'Name';
                  lastName = updatedSnapshot.get('lastName') ?? 'Name';
                  chats = List<String>.from(updatedSnapshot.get("chats") ?? []);
                });
                sortChatsByLatestMessage(); // Sort chats whenever profile updates
              }
            });
      } else {
        // Handle case where user profile is not found
      }
    } catch (e) {
      // Handle error loading profile
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

            sortChatsByLatestMessage(); // Sort chats whenever new messages are received
          } else {
            setState(() {
              chats = [];
            });
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

      setState(() {
        chatSubtitles[groupID] = content;
      });
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
}
