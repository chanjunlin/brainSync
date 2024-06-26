import 'package:brainsync/common_widgets/home_post_card.dart';
import 'package:brainsync/model/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../common_widgets/bottomBar.dart';
import '../common_widgets/navBar.dart';
import '../const.dart';
import '../model/time.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late Future<QuerySnapshot> allPosts;
  late TextEditingController searchQuery = TextEditingController();
  late User? user;

  String? userProfilePfp, userProfileCover, firstName, lastName;
  final GetIt _getIt = GetIt.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Map<String, bool> _bookmarks = {};

  List<DocumentSnapshot> filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    allPosts = _databaseService.fetchPosts();
    user = _authService.currentUser;
    searchQuery = TextEditingController();
    loadProfile();
    timeago.setLocaleMessages('custom', CustomShortMessages());
  }

  @override
  void dispose() {
    searchQuery.dispose();
    super.dispose();
  }

  void filterTitles(String query) async {
    final posts = await allPosts;
    List<DocumentSnapshot> filteringPosts = posts.docs.where((post) {
      String title = post['title'].toString().toLowerCase();
      String content = post['content'].toString().toLowerCase();
      return title.contains(query.toLowerCase()) || content.contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredPosts = filteringPosts;
    });
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchQuery,
              onChanged: filterTitles,
              decoration: InputDecoration(
                hintText: 'Search for modules with Code or Title',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      searchQuery.clear();
                      filteredPosts = []; // Clear filtered posts
                    });
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 10.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.brown, width: 2.0),
                ),
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
                  return const Center(child: Text("Something went wrong"));
                }

                List<DocumentSnapshot> posts = [];
                if (filteredPosts.isNotEmpty) {
                  posts = filteredPosts;
                } else {
                  posts = snapshot.data!.docs;
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    print(posts[index]);
                    final post = posts[index].data() as Post;
                    print(post);
                    final isBookMarked = _bookmarks[post] ?? false;
                    return PostCard(
                      postId: post.id!,
                      postData: post,
                      isBookmark: isBookMarked,

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
        List<String> bookmarks =
        List<String>.from(userProfile.get('bookmarks') ?? []);
        setState(() {
          userProfilePfp = userProfile.get('pfpURL') ?? PLACEHOLDER_PFP;
          userProfileCover =
              userProfile.get('profileCoverURL') ?? PLACEHOLDER_PROFILE_COVER;
          firstName = userProfile.get('firstName') ?? 'Name';
          lastName = userProfile.get('lastName') ?? 'Name';
          for (var postId in bookmarks) {
            _bookmarks[postId] = true;
          }
        });
      } else {
        print('User profile not found');
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

// Remaining methods like likePost, dislikePost, bookmark, etc.
}
