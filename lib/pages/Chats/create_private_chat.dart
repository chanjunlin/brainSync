import 'package:brainsync/pages/Chats/private_chat/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../common_widgets/chat_tile.dart';
import '../../const.dart';
import '../../model/user_profile.dart';
import '../../services/database_service.dart';
import '../../services/navigation_service.dart';

class PrivateChat extends StatefulWidget {
  @override
  _PrivateChatState createState() => _PrivateChatState();
}

class _PrivateChatState extends State<PrivateChat> {
  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a Private Message'),
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<UserProfile?>>(
        future: _databaseService.getFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/img/sad_brain.png"),
                  const SizedBox(height: 16),
                  Text(
                    'No friends found',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.brown[700],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Material(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  UserProfile? friend = snapshot.data![index];
                  if (friend == null) return SizedBox.shrink(); // Handle null friend case

                  return CustomChatTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(friend.pfpURL ?? PLACEHOLDER_PFP),
                    ),
                    title: "${friend.firstName} ${friend.lastName}",
                    subtitle: friend.bio ?? 'No bio available',
                    onTap: () {
                      _navigationService.push(
                        MaterialPageRoute(
                            builder: (context) {
                              return ChatPage(
                                  chatUser: friend);
                            }),
                      );
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

}
