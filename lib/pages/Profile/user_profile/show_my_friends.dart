import 'package:brainsync/common_widgets/chat_tile.dart';
import 'package:brainsync/const.dart';
import 'package:brainsync/model/user_profile.dart';
import 'package:brainsync/pages/Profile/visiting_profile/visiting_profile.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShowMyFriends extends StatefulWidget {
  const ShowMyFriends({super.key});

  @override
  State<ShowMyFriends> createState() => _ShowMyFriendsState();
}

class _ShowMyFriendsState extends State<ShowMyFriends> {
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
    final Size screenSize = MediaQuery.of(context).size;

    return FutureBuilder<List<UserProfile?>>(
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
              children: [
                Image.asset(
                  "assets/img/sad_brain.png",
                  height: screenSize.height * 0.3,
                  width: screenSize.width * 0.5,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 15),
                Text(
                  'No friends found',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.05,
                    color: Colors.brown[700],
                  ),
                ),
              ],
            ),
          );
        } else {
          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.02,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              UserProfile? friend = snapshot.data![index];
              return CustomChatTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(friend!.pfpURL ?? placeholderPFP),
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
