import 'dart:core';

import 'package:brainsync/common_widgets/bottomBar.dart';
import 'package:brainsync/common_widgets/navBar.dart';
import 'package:brainsync/model/time.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../services/navigation_service.dart';
import 'Posts/actual_post.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late User? user;

  String? name;

  late AuthService _authService;
  late NavigationService _navigationService;
  late DatabaseService _databaseService;

  final GetIt _getIt = GetIt.instance;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _databaseService = _getIt.get<DatabaseService>();
    user = _authService.currentUser;
    loadProfile();
    timeago.setLocaleMessages('custom', CustomShortMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        title: const Text("BrainSync"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          final posts = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index].data() as Map<String, dynamic>;
              final timestamp = post['timestamp'] as Timestamp;
              final date = timestamp.toDate();
              final formattedDate = timeago.format(date, locale: 'custom');

              return Card(
                color: Colors.white, // Complementary color to brown
                shape: const RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.brown,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.zero),
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailPage(
                          postId: posts[index].id,
                          title: post['title'],
                          timestamp: date,
                          content: post['content'],
                          authorName: post['authorName'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              post['title'],
                              style: TextStyle(
                                color: Colors.brown[800],
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(color: Colors.brown.shade800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          post['content'],
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.brown[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(initialIndex: 0),
    );
  }

  void loadProfile() async {
    try {
      DocumentSnapshot? userProfile = await _databaseService.fetchCurrentUser();
      print(userProfile);
      if (userProfile != null && userProfile.exists) {
        setState(() {
          name = userProfile.get('firstName') ?? 'Name';
        });
      } else {
        print('User profile not found');
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }
}
