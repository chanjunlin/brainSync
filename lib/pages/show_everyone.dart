import 'package:brainsync/auth.dart';
import 'package:brainsync/common_widgets/user_tile.dart';
import 'package:brainsync/pages/visiting_profile.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../common_widgets/chat_tile.dart';
import '../model/user_profile.dart'; // Assuming you have a UserProfile model defined

class ShowEveryone extends StatefulWidget {
  @override
  State<ShowEveryone> createState() => _ShowEveryoneState();
}

class _ShowEveryoneState extends State<ShowEveryone> {
  late DatabaseService _databaseService;
  late AuthService _authService;
  late NavigationService _navigationService;

  final GetIt _getIt = GetIt.instance;

  @override
  void initState() {
    _databaseService = _getIt.get<DatabaseService>();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _chatList(),
          ElevatedButton(
            onPressed: () async {
              _navigationService.pushName("/home");
            },
            child: Text("home"),
          ),
        ],
      ),
    );
  }

  Widget _chatList() {
    return StreamBuilder(
      stream: _databaseService.getUserProfiles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Unable to load data"),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          final users = snapshot.data!.docs;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              UserProfile user = users[index].data();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: UserTile(
                  userProfile: user,
                  onTap: () async {
                    final chatExists = await _databaseService.checkChatExist(
                        _authService.user!.uid, user.uid!);
                    if (!chatExists) {
                      await _databaseService.createNewChat(
                          _authService.user!.uid, user.uid!);
                    }
                    _navigationService.push(
                      MaterialPageRoute(builder: (context) {
                        return VisitingProfile(
                          userId: user,
                        );
                      }),
                    );
                  },
                ),
              );
            },
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
