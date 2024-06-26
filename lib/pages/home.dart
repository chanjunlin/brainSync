import 'dart:core';

import 'package:brainsync/common_widgets/bottomBar.dart';
import 'package:brainsync/common_widgets/navBar.dart';
import 'package:brainsync/model/bookmarchangenotifier.dart';
import 'package:brainsync/model/time.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../const.dart';
import '../services/alert_service.dart';
import 'Posts/actual_post.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  String searchQuery = "";
  List? friendReqList, currentModules, completedModules;
  String? userProfilePfp, userProfileCover, firstName, lastName;

  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late User? user;

  final GetIt _getIt = GetIt.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    user = _authService.currentUser;
    loadProfile();
    timeago.setLocaleMessages('custom', CustomShortMessages());
  }

  Future<void> likePost(BuildContext context, String postId) async {
    try {
      await _databaseService.likePost(postId);
    } catch (e) {
      _alertService.showToast(text: "Error liking post", icon: Icons.error);
    }
  }

  Future<void> dislikePost(BuildContext context, String postId) async {
    try {
      await _databaseService.dislikePost(postId);
    } catch (e) {
      _alertService.showToast(text: "Error disliking post", icon: Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        title: !isSearching
            ? const Text("BrainSync")
            : TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchQuery = "";
                }
              });
            },
            icon: Icon(isSearching ? Icons.close : Icons.search),
          )
        ],
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, child) {
          return StreamBuilder<QuerySnapshot>(
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

              final posts = snapshot.data?.docs.where((post) {
                    if (searchQuery.isEmpty) return true;
                    final data = post.data() as Map<String, dynamic>;
                    final title = data['title'] as String;
                    return title
                        .toLowerCase()
                        .startsWith(searchQuery.toLowerCase());
                  }).toList() ??
                  [];

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index].data() as Map<String, dynamic>;
                  final postId = posts[index].id;
                  final timestamp = post['timestamp'] as Timestamp;
                  final date = timestamp.toDate();
                  final formattedDate = timeago.format(date, locale: 'custom');
                  final likes = post['likes'] ?? [];
                  final isLiked = likes.contains(userId);
                  final likeCount = likes.length;
                  final commentCount = post['commentCount'] ?? 0;
                  final isBookmarked = bookmarkProvider.bookmarks[postId] ?? false;

                  return Card(
                    color: Colors.white,
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
                      child: Padding(
                        padding: const EdgeInsets.all(10),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isLiked
                                            ? Icons.thumb_up
                                            : Icons.thumb_up_outlined,
                                        color: isLiked
                                            ? Colors.brown[300]
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        if (isLiked) {
                                          dislikePost(context, posts[index].id);
                                        } else {
                                          likePost(context, posts[index].id);
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 5),
                                    Text('$likeCount',
                                        style: TextStyle(color: Colors.brown[800])),
                                  ],
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.comment,
                                          color: Color.fromARGB(255, 161, 136, 127),
                                        ),
                                        onPressed: () {
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
                                      ),
                                      const SizedBox(width: 5),
                                      Text('$commentCount',
                                          style:
                                              TextStyle(color: Colors.brown[800])),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isBookmarked
                                            ? Icons.bookmark
                                            : Icons.bookmark_outline,
                                        color: isBookmarked
                                            ? Colors.brown[400]
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        bookmarkProvider.toggleBookmark(postId);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 0),
    );
  }

  void loadProfile() async {
    try {
      DocumentSnapshot? userProfile = await _databaseService.fetchCurrentUser();
      if (userProfile != null && userProfile.exists) {
        setState(() {
          userProfilePfp = userProfile.get('pfpURL') ?? PLACEHOLDER_PFP;
          userProfileCover =
              userProfile.get('profileCoverURL') ?? PLACEHOLDER_PROFILE_COVER;
          firstName = userProfile.get('firstName') ?? 'Name';
          lastName = userProfile.get('lastName') ?? 'Name';
        });
      } else {
        print('User profile not found');
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }
}
