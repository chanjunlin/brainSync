import 'package:brainsync/common_widgets/home_post_card.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../common_widgets/bottom_bar.dart';
import '../common_widgets/nav_bar.dart';
import '../services/alert_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with RouteAware {
  final GetIt _getIt = GetIt.instance;

  late AlertService _alertService;
  late DatabaseService _databaseService;
  late TextEditingController searchQuery;
  late Future<QuerySnapshot> allPostsFuture;
  List<DocumentSnapshot> allPosts = [];
  List<DocumentSnapshot> filteredPosts = [];
  List<dynamic> bookmarks = [];

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    searchQuery = TextEditingController();
    searchQuery.addListener(_onSearchChanged);
    allPostsFuture = fetchPosts();
    loadProfile();
  }

  @override
  void dispose() {
    searchQuery.removeListener(_onSearchChanged);
    searchQuery.dispose();
    super.dispose();
  }

  Future<QuerySnapshot> fetchPosts() async {
    final postsSnapshot =
        await FirebaseFirestore.instance.collection('posts').get();
    setState(() {
      allPosts = postsSnapshot.docs;
      filteredPosts = allPosts;
    });
    return postsSnapshot;
  }

  void _onSearchChanged() {
    final query = searchQuery.text.toLowerCase();
    setState(() {
      filteredPosts = allPosts.where((post) {
        final title = post['title'].toString().toLowerCase();
        return query.isEmpty || title.startsWith(query);
      }).toList();
    });
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
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: const NavBar(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        title: const Text('BrainSync'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.1),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: TextField(
              cursorColor: Colors.brown[300],
              style: TextStyle(
                color: Colors.brown[800],
              ),
              controller: searchQuery,
              onChanged: (value) => _onSearchChanged(),
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
                contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  borderSide:
                      BorderSide(color: Colors.brown.shade300, width: 2.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: allPostsFuture,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            allPosts = snapshot.data!.docs;
            filteredPosts = filteredPosts.isEmpty ? allPosts : filteredPosts;
            filteredPosts.sort((a, b) {
              Timestamp timestampA = a['timestamp'];
              Timestamp timestampB = b['timestamp'];
              return timestampB.compareTo(timestampA);
            });
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final slideTransition = SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
              return slideTransition;
            },
            child: filteredPosts.isEmpty
                ? Center(
                    key: const ValueKey('empty'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/img/magnifying_glass_brain.png",
                          width: screenWidth * 0.5,
                          height: screenHeight * 0.3,
                        ),
                        Text(
                          'No posts found',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: Colors.brown[700],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    key: ValueKey(filteredPosts.length),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot post = filteredPosts[index];
                      return HomePostCard(
                        postId: post.id,
                      );
                    },
                  ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 0),
    );
  }
}
