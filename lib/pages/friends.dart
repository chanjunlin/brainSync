import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/user_profile.dart';

class FriendListPage extends StatelessWidget {
  final List<UserProfile?> friendList;

  const FriendListPage({
    Key? key,
    required this.friendList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend List'),
      ),
      body: ListView.builder(
        itemCount: friendList.length,
        itemBuilder: (context, index) {
          UserProfile? userProfile = friendList[index];
          return ListTile(
            title: Text(userProfile?.firstName ?? ''),
            subtitle: Text(userProfile?.lastName ?? ''),
            // Add more fields as needed
          );
        },
      ),
    );
  }
}
