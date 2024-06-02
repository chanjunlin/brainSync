import 'package:flutter/material.dart';

import '../model/user_profile.dart';

class UserTile extends StatelessWidget {
  final UserProfile userProfile;
  final Function onTap;

  const UserTile({
    super.key,
    required this.userProfile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTap();
      },
      dense: false,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userProfile.pfpURL!),
      ),
      title: Text(
        userProfile.firstName!,
      ),
    );
  }
}
