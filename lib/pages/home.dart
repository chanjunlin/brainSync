import 'package:brainsync/common_widgets/home_post_card.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../common_widgets/bottomBar.dart';
import '../common_widgets/navBar.dart';
import '../services/alert_service.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with RouteAware {
  final GetIt _getIt = GetIt.instance;

  late AlertService _alertService;
  late DatabaseService _databaseService;
  late TextEditingController searchQuery;
  late Future<QuerySnapshot> allPosts;
  late Future<void> loadedProfile;

  List<dynamic>? bookmarks;
  List<DocumentSnapshot> filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    loadedProfile = loadProfile();
    searchQuery = TextEditingController();
    allPosts = fetchPosts();
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

  Future<void> loadProfile() async {
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

  void clearSearch() {
    searchQuery.clear();
    filterTitles('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        title: const Text('BrainSync'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              cursorColor: Colors.brown[300],
              style: TextStyle(
                color: Colors.brown[800],
              ),
              controller: searchQuery,
              onChanged: filterTitles,
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.brown[700],
                ),
                hintText: 'Search for module code',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search, color: Colors.brown[300]),
                suffixIcon: searchQuery.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.brown[300]),
                        onPressed: clearSearch,
                      )
                    : null,
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
                  borderSide:
                      BorderSide(color: Colors.brown.shade300, width: 2.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([allPosts, loadedProfile]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          QuerySnapshot postsSnapshot = snapshot.data![0];
          List<DocumentSnapshot> posts =
              filteredPosts.isNotEmpty ? filteredPosts : postsSnapshot.docs;
          posts.sort((a, b) {
            Timestamp timestampA = a['timestamp'];
            Timestamp timestampB = b['timestamp'];
            return timestampB.compareTo(timestampA);
          });

          return posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/img/brain.png"),
                      Text(
                        'No posts',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.brown[700],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot post = posts[index];
                          return HomePostCard(
                            postId: post.id,
                          );
                        },
                      ),
                    ),
                  ],
                );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 0),
    );
  }
}
