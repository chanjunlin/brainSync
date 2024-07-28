import 'package:brainsync/pages/Profile/visiting_profile/visiting_profile.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../common_widgets/chat_tile.dart';
import '../../../const.dart';
import '../../../model/user_profile.dart';
import '../../../services/database_service.dart';
import '../../../services/navigation_service.dart';

class ShowUserFriends extends StatefulWidget {
  final String userID;

  const ShowUserFriends({
    super.key,
    required this.userID,
  });

  @override
  State<ShowUserFriends> createState() => _ShowUserFriendsState();
}

class _ShowUserFriendsState extends State<ShowUserFriends> {
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
    return FutureBuilder<List<UserProfile?>>(
      future: _databaseService.getMutualFriends(
          _authService.currentUser!.uid, widget.userID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              children: [
                Image.asset(
                  "assets/img/sad_brain.png",
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 0.5,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 15),
                const Text('No mutual friends')
              ],
            ),
          );
        } else {
          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width *
                  0.02,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              UserProfile? friend = snapshot.data![index];
              return CustomChatTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(friend!.pfpURL ?? placeholderPFP),
                ),
                title: "${friend.firstName} ${friend.lastName}",
                subtitle: friend.bio ?? 'No bio available',
                onTap: () {
                  _navigationService.push(
                    MaterialPageRoute(builder: (context) {
                      return VisitProfile(
                        userId: friend.uid as String,
                      );
                    }),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
