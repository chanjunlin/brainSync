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
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late Future<QuerySnapshot> allPosts;
  late List<DocumentSnapshot> filteredPosts = [];
  late TextEditingController searchQuery = TextEditingController();
  late User? user;

  List? friendReqList, currentModules, completedModules;
  List<dynamic>? bookmarks;
  String? userProfilePfp, userProfileCover, firstName, lastName;

  final GetIt _getIt = GetIt.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    allPosts = _databaseService.fetchPosts();
    user = _authService.currentUser;
    searchQuery = TextEditingController();
    searchQuery.addListener(filterTitles);
    loadProfile();
    timeago.setLocaleMessages('custom', CustomShortMessages());
  }

  @override
  void dispose() {
    searchQuery.dispose();
    super.dispose();
  }

  void filterTitles() async {
    final postsSnapshot = await allPosts;
    List<DocumentSnapshot<Object?>> filteringPosts = postsSnapshot.docs
        .where((post) => post['title'].toString().contains(searchQuery.text))
        .toList();
    setState(() {
      filteredPosts = filteringPosts;
    });
  }

  void clearSearch() {
    searchQuery.clear();
    filterTitles();
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchQuery,
              onChanged: (query) => setState(() {}),
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
                    });
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 10.0),
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
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: allPosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                List<DocumentSnapshot> posts = filteredPosts.isNotEmpty
                    ? filteredPosts
                    : snapshot.data!.docs;
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final postData = posts[index].data()! as Post;
                    bool isBookmark = bookmarks!.contains(posts[index].id);
                    return Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: PostCard(
                        postId: posts[index].id,
                        postData: postData,
                        isBookmark: isBookmark,
                      ),
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
          userProfilePfp = userProfile.get('pfpURL') ?? PLACEHOLDER_PFP;
          userProfileCover =
              userProfile.get('profileCoverURL') ?? PLACEHOLDER_PROFILE_COVER;
          firstName = userProfile.get('firstName') ?? 'Name';
          lastName = userProfile.get('lastName') ?? 'Name';
          bookmarks = userProfile.get('bookmarks') ?? [];
        });
      } else {
        print('User profile not found');
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }
}
