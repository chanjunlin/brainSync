import 'package:brainsync/services/database_service.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../model/user_profile.dart';
import '../services/auth_service.dart';

class VisitingProfile extends StatefulWidget {
  final UserProfile userId;

  VisitingProfile({required this.userId});

  @override
  State<VisitingProfile> createState() => _VisitingProfileState();
}

class _VisitingProfileState extends State<VisitingProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late DatabaseService _databaseService;
  late String userToAdd;

  ChatUser? currentUser, otherUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    // _mediaService = _getIt.get<MediaService>();
    // _storageService = _getIt.get<StorageService>();

    currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _authService.user!.displayName,
    );
    otherUser = ChatUser(
      id: widget.userId.uid!,
      firstName: widget.userId.firstName!,
      profileImage: widget.userId.pfpURL,
    );
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(widget.userId!.uid).get(),
        builder: (context, snapshot) {
          print("one");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User not found'));
          }

          print('two');
          print(currentUser!.id);
          print(otherUser!.id);
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String? pfpURL = userData['pfpURL'];
          String? firstName = userData['firstName'];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(userData['pfpURL']),
                ),
                SizedBox(height: 16),
                Text(
                  userData['firstName'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _databaseService.sendFriendRequest(currentUser!.id, otherUser!.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Friend request sent!')),
                    );
                  },
                  child: Text('Add Friend'),
                ),
                // Add more user details here as needed
              ],
            ),
          );
        },
      ),
    );
  }
}
