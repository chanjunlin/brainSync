import 'dart:async';

import 'package:brainsync/pages/Chats/group_chat/show_group_chat.dart';
import 'package:brainsync/pages/Chats/private_chat/show_private_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../common_widgets/bottomBar.dart';
import '../../const.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/navigation_service.dart';

class FriendsChats extends StatefulWidget {
  final int? tabNumber;

  const FriendsChats({
    super.key,
    this.tabNumber,
  });

  @override
  FriendsChatsState createState() => FriendsChatsState();
}

class FriendsChatsState extends State<FriendsChats> {
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
  void dispose() {
    profileSubscription?.cancel();
    chatsSubscription?.cancel();
    super.dispose();
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

        sortChatsByLatestMessage();

        profileSubscription =
            userProfile.reference.snapshots().listen((updatedSnapshot) {
          if (updatedSnapshot.exists) {
            setState(() {
              userProfilePfp = updatedSnapshot.get('pfpURL') ?? PLACEHOLDER_PFP;
              firstName = updatedSnapshot.get('firstName') ?? 'Name';
              lastName = updatedSnapshot.get('lastName') ?? 'Name';
              chats = List<String>.from(updatedSnapshot.get("chats") ?? []);
            });
            sortChatsByLatestMessage();
          }
        });
      } else {}
    } catch (e) {}
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

        sortChatsByLatestMessage();
      } else {
        setState(() {
          chats = [];
        });
      }
    });
  }

  void updateChatSubtitle(String chatId, String content, Timestamp? sentAt) {
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
        chatSubtitles[chatId] = content;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Chats",
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              chatCreationMenu(context);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: buildTabBarSection(),
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 1),
    );
  }

  Widget buildTabBarSection() {
    final int initialIndex = widget.tabNumber ?? 0;

    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.brown[800],
            unselectedLabelColor: Colors.brown[400],
            tabs: const [
              Tab(text: 'Private chats'),
              Tab(text: 'Group Chats'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                showPrivateChat(),
                showGroupChat(),
              ],
            ),
          ),
        ],
      ),
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

  Widget showPrivateChat() {
    return const ShowPrivateChat();
  }

  Widget showGroupChat() {
    return const ShowGroupChat();
  }

  void chatCreationMenu(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('New Private Chat'),
                onTap: () {
                  Navigator.pop(context);
                  _navigationService.pushName("/privateChat");
                },
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('New Group Chat'),
                onTap: () {
                  Navigator.pop(context);
                  _navigationService.pushName("/groupChat");
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
