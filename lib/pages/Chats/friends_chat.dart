import 'dart:async';

import 'package:brainsync/services/alert_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../common_widgets/bottomBar.dart';
import '../../common_widgets/chat_tile.dart';
import '../../const.dart';
import '../../model/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/navigation_service.dart';
import 'chat_page.dart';

class FriendsChats extends StatefulWidget {
  const FriendsChats({super.key});

  @override
  FriendsChatsState createState() => FriendsChatsState();
}

class FriendsChatsState extends State<FriendsChats> {
  final GetIt _getIt = GetIt.instance;

  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;

  late Future<void> listenedToChats;
  late Future<void> loadedProfile;

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
    _alertService = _getIt.get<AlertService>();
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
        profileSubscription =
            userProfile.reference.snapshots().listen((updatedSnapshot) {
          if (updatedSnapshot.exists) {
            setState(() {
              userProfilePfp = updatedSnapshot.get('pfpURL') ?? PLACEHOLDER_PFP;
              firstName = updatedSnapshot.get('firstName') ?? 'Name';
              lastName = updatedSnapshot.get('lastName') ?? 'Name';
              chats = List<String>.from(updatedSnapshot.get("chats") ?? []);
            });
          }
        });
      } else {
        _alertService.showToast(
            text: "User profile not found", icon: Icons.error_outline_rounded);
      }
    } catch (e) {
      _alertService.showToast(
          text: "Error loading profile: $e", icon: Icons.error_outline_rounded);
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
                if (!chats!.contains(chatId)) {
                  chats!.add(chatId);
                }
                lastMessageTimestamps[chatId] = lastMessageTimestamp;
              });
              updateChatSubtitle(chatId, lastMessageData['content']);
            }
          }
        }

        chats!.sort((a, b) {
          Timestamp? aTimestamp = lastMessageTimestamps[a];
          Timestamp? bTimestamp = lastMessageTimestamps[b];
          if (aTimestamp == null || bTimestamp == null) return 0;
          return bTimestamp.compareTo(aTimestamp);
        });
      } else {
        setState(() {
          chats = [];
        });
      }
    });
  }

  void updateChatSubtitle(String chatId, String content) {
    setState(() {
      chatSubtitles[chatId] = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: chats != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (chats!.isEmpty)
                    Column(
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
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                                child: Text(
                                  'Error: ${snapshot.error}',
                                ),
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data != null) {
                              DocumentSnapshot<Object?> chatDetails =
                                  snapshot.data!;
                              String chatSubtitle = chatSubtitles[chatId] ?? "";
                              List<dynamic> participantsIds =
                                  chatDetails.get('participantsIds') ?? [];
                              String otherUserId = participantsIds.firstWhere(
                                (id) => id != _authService.currentUser!.uid,
                                orElse: () => null,
                              );
                              List<dynamic> participantsNames =
                                  chatDetails.get('participantsNames') ?? [];
                              String otherUserName =
                                  participantsNames.firstWhere(
                                (name) =>
                                    name !=
                                    _authService.currentUser!.displayName,
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
                                      child:
                                          Text('Error: ${userSnapshot.error}'),
                                    );
                                  } else if (userSnapshot.hasData &&
                                      userSnapshot.data != null) {
                                    UserProfile otherUser =
                                        UserProfile.fromJson(userSnapshot.data!
                                            .data() as Map<String, dynamic>);
                                    return CustomChatTile(
                                      leading: CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                            otherUser.pfpURL ??
                                                PLACEHOLDER_PFP),
                                      ),
                                      title: otherUserName,
                                      subtitle: chatSubtitle,
                                      onTap: () {
                                        _navigationService.push(
                                          MaterialPageRoute(builder: (context) {
                                            return ChatPage(
                                                chatUser: otherUser);
                                          }),
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
                                child: Text('Chat details not found'),
                              );
                            }
                          },
                        );
                      },
                    ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 1),
    );
  }
}
