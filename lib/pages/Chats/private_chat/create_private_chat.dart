import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../common_widgets/chat_tile.dart';
import '../../../const.dart';
import '../../../model/user_profile.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../../services/navigation_service.dart';
import 'chat_page.dart';

class PrivateChat extends StatefulWidget {
  const PrivateChat({super.key});

  @override
  PrivateChatState createState() => PrivateChatState();
}

class PrivateChatState extends State<PrivateChat> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Start a new chat'),
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
                  Image.asset(
                    'assets/img/sad_brain.png',
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Image failed to load');
                    },
                  ),
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
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                UserProfile? friend = snapshot.data![index];
                if (friend == null) return const SizedBox.shrink();
                return CustomChatTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage(friend.pfpURL ?? placeholderPFP),
                  ),
                  title: "${friend.firstName} ${friend.lastName}",
                  subtitle: friend.bio ?? 'No bio available',
                  onTap: () async {
                    final chatExists = await _databaseService.checkChatExist(
                        _authService.currentUser!.uid, friend.uid!);
                    if (!chatExists) {
                      await _databaseService.createNewChat(
                          _authService.currentUser!.uid, friend.uid!);
                    }
                    UserProfile? user =
                        await _databaseService.fetchUserProfile(friend.uid!);
                    _navigationService.push(
                      MaterialPageRoute(
                        builder: (context) {
                          return ChatPage(chatUser: user);
                        },
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
