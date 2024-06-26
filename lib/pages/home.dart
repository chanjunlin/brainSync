import 'package:brainsync/common_widgets/home_post_card.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../common_widgets/bottomBar.dart';
import '../common_widgets/navBar.dart';
import '../model/post.dart';
import '../model/time.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GetIt _getIt = GetIt.instance;

  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late TextEditingController searchQuery;
  late Future<QuerySnapshot> allPosts;

  List<dynamic>? bookmarks;
  List<DocumentSnapshot> filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    loadProfile();
    searchQuery = TextEditingController();
    allPosts = fetchPosts();
    timeago.setLocaleMessages('custom', CustomShortMessages());
  }

  @override
  void dispose() {
    searchQuery.dispose();
    super.dispose();
  }

  Future<QuerySnapshot> fetchPosts() async {
    return FirebaseFirestore.instance.collection('posts').get();
  }

  void filterTitles(String query) async {
    try {
      final posts = await allPosts;

      setState(() {
        filteredPosts = posts.docs
            .where((post) => post['title']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    } catch (e) {
      _alertService.showToast(text: 'Error filtering posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        title: const Text('BrainSync'),
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchQuery,
              onChanged: filterTitles,
              decoration: const InputDecoration(
                hintText: 'Search by title',
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: allPosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                List<DocumentSnapshot> posts = [];
                if (filteredPosts.isNotEmpty) {
                  posts = filteredPosts;
                } else {
                  posts = snapshot.data!.docs;
                }

                posts.sort((a, b) {
                  Timestamp timestampA = a['timestamp'];
                  Timestamp timestampB = b['timestamp'];
                  return timestampB.compareTo(timestampA);
                });

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot post = posts[index];
                    Post postData =
                        Post.fromJson(post.data() as Map<String, dynamic>);
                    return HomePostCard(
                      postId: post.id,
                      postData: postData,
                      title: postData.title,
                      content: postData.content,
                      authorName: postData.authorName,
                      timeStamp: postData.timestamp?.toDate(),
                      likeCount: postData.likes?.length,
                      commentCount: postData.commentCount ?? 0,
                      isLiked: postData.likes
                          ?.contains(_authService.currentUser!.uid),
                      isBookmark: bookmarks!.contains(post.id),
                      likes: postData.likes,
                      userBookmarks: [],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 0),
    );
  }

  void loadProfile() async {
    try {
      DocumentSnapshot? userProfile = await _databaseService.fetchCurrentUser();
      if (userProfile != null && userProfile.exists) {
        setState(() {
          bookmarks = userProfile.get('bookmarks') ?? [];
        });
      } else {
        _alertService.showToast(text: 'User profile not found');
      }
    } catch (e) {
      _alertService.showToast(text: 'Error loading profile: $e');
    }
  }
}
