import 'package:brainsync/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../common_widgets/home_post_card.dart';
import '../../model/post.dart'; // Assuming your Post model is correctly defined here
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class BookmarkedPosts extends StatefulWidget {
  const BookmarkedPosts({
    Key? key,
  }) : super(key: key);

  @override
  _BookmarkedPostsState createState() => _BookmarkedPostsState();
}

class _BookmarkedPostsState extends State<BookmarkedPosts> {
  final GetIt _getIt = GetIt.instance;
  Map<String, bool> _bookmarks = {}; // Changed to non-late to update in initState

  late String userID;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;
  late Future<List<DocumentSnapshot>> bookmarkedPosts;
  late Future<void> loadedBookmarks;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
    userID = _authService.currentUser!.uid;
    bookmarkedPosts = _databaseService.fetchBookmarkedPosts();
    loadedBookmarks = loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    try {
      final userRef =
      FirebaseFirestore.instance.collection('users').doc(userID);
      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        List<String> bookmarks =
        List<String>.from(userSnapshot.data()?['bookmarks'] ?? []);
        setState(() {
          _bookmarks.clear();
          for (var postId in bookmarks) {
            _bookmarks[postId] = true;
          }
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bookmarkedPosts = _databaseService.fetchBookmarkedPosts();
    loadBookmarks();
  }

  Future<void> refresh() {
    return Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        title: const Text(
          "Bookmarked posts",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _navigationService.pushName("/home");
          },
        ),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: bookmarkedPosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/img/brain.png"),
                  const Text(
                    'No bookmarked posts',
                    style: TextStyle(color: Color.fromARGB(255, 78, 52, 46)),
                  ),
                  const SizedBox(width: 60),
                ],
              ),
            );
          }

          final bookmarkedPosts = snapshot.data!;

          return ListView.builder(
            itemCount: bookmarkedPosts.length,
            itemBuilder: (context, index) {
              DocumentSnapshot postSnapshot = bookmarkedPosts[index];
              if (!postSnapshot.exists) {
                return const SizedBox.shrink();
              }
              String postId = postSnapshot.id;
              if (_bookmarks.containsKey(postId)) {
                return HomePostCard(
                  postId: postId,
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }
}