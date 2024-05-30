import 'dart:convert';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brainsync/navBar.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:core';

import 'package:brainsync/pages/profile.dart';
import '../services/navigation_service.dart';
import 'actual_post';
import 'post.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:brainsync/model/time.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final User? user = AuthService().currentUser;

  String? name;

  late AuthService _authService;
  late NavigationService _navigationService;
  late DatabaseService _databaseService;

  final GetIt _getIt = GetIt.instance;

  @override
  void initState() {
    super.initState();
    // _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _databaseService = _getIt.get<DatabaseService>();
    loadProfile();
    timeago.setLocaleMessages('custom', CustomShortMessages());
  }

  List _items = [];

  // Future<void> getMods() async {
  //   var url = await http.get(
  //       Uri.https("api.nusmods.com", "v2/2018-2019/modules/CS2040.json"));
  //   var jsonData = await jsonDecode(url.body);
  //   for (var mods in jsonData)
  //     print(mods);
  // }

  @override
  Widget build(BuildContext context) {
    // getMods();

    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Row(
          children: [ElevatedButton(
              onPressed: () async {
              _navigationService.pushName("/friendsChat");
            },
              child: const Text("see friends"),
            )
        ],
        )
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
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
                color: Theme.of(context).colorScheme.primary,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [ Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Text(
                          post['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(color: Color.fromARGB(255, 202, 197, 197)),
                        ),
                        ],
                      ),
                        const SizedBox(height: 10),
                        Text(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          post['content'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
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
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 20,
          ),
          child: GNav(
            backgroundColor: Colors.black,
            tabBackgroundColor: Colors.grey,
            color: Colors.white,
            activeColor: Colors.white,
            gap: 8,
            tabs: [
              const GButton(
                icon: Icons.home,
                text: "Home",
              ),
              GButton(
                icon: Icons.chat,
                text: "Chats",
                onPressed: () async {
                  _navigationService.pushName(
                    "/friendsChat",
                  );
                },
              ),
              GButton(
                icon: Icons.add,
                text: "Create",
                onPressed: () async {
                  _navigationService.pushName("/post");
                },
              ),
              GButton(
                icon: Icons.person_2,
                text: "Profile",
                onPressed: () async {
                  _navigationService.pushName("/profile");
                },
              ),
            ],
            selectedIndex: 0,
          ),
        ),
      ),
    );
  }

  void loadProfile() async {
    try {
      DocumentSnapshot? userProfile = await _databaseService.fetchUser();
      if (userProfile != null && userProfile.exists) {
        setState(() {
          // userProfilePfp = userProfile.get('pfpURL') ?? PLACEHOLDER_PFP;
          name = userProfile.get('firstName') ?? 'Name'; // Example field
        });
      } else {
        print('User profile not found');
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }
}
