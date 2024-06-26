import 'package:brainsync/common_widgets/dialog.dart';
import 'package:brainsync/model/bookmarchangenotifier.dart';
import 'package:brainsync/model/time.dart';
import 'package:brainsync/pages/Posts/actual_post.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class Saved extends StatefulWidget {
  const Saved({super.key});

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  late User? user;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late BookmarkProvider _bookmarkProvider;

  final GetIt _getIt = GetIt.instance;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    user = _authService.currentUser;
    timeago.setLocaleMessages('custom', CustomShortMessages());
    _bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
  }

  Future<void> likePost(BuildContext context, String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([_bookmarkProvider.userId])
      });
    } on FirebaseException {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error liking post')));
    }
  }

  Future<void> dislikePost(BuildContext context, String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([_bookmarkProvider.userId])
      });
    } on FirebaseException {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error disliking post')));
    }
  }

  Future<int> getCommentCount(String postId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();
    return querySnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = _bookmarkProvider.bookmarks;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        title: const Text("Saved", style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(_bookmarkProvider.userId).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text('No saved posts'));
          }

          List<String> bookmarkIds = bookmarks.keys.where((key) => bookmarks[key] == true).toList();
          if (bookmarkIds.isEmpty) {
            return const Center(child: Text('No saved posts'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .where(FieldPath.documentId, whereIn: bookmarkIds)
                .snapshots(),
            builder: (context, postSnapshot) {
              if (postSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!postSnapshot.hasData || postSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No saved posts'));
              }

              final bookmarkedPosts = postSnapshot.data!.docs;

              return ListView.builder(
                itemCount: bookmarkedPosts.length,
                itemBuilder: (context, index) {
                  final post = bookmarkedPosts[index].data() as Map<String, dynamic>;
                  final postId = bookmarkedPosts[index].id;
                  final timestamp = post['timestamp'] as Timestamp;
                  final date = timestamp.toDate();
                  final formattedDate = timeago.format(date, locale: 'custom');
                  final likes = post['likes'] ?? [];
                  final isLiked = likes.contains(_bookmarkProvider.userId);
                  final likeCount = likes.length;
                  final commentCount = post['commentCount'] ?? 0;
                  final isBookmarked = bookmarks[postId] ?? true;

                  return Card(
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.brown, width: 1.0),
                      borderRadius: BorderRadius.zero,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailPage(
                              postId: postId,
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
                              post['content'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 15, color: Colors.brown[800]),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                    color: isLiked ? Colors.brown[300] : Colors.grey,
                                  ),
                                  onPressed: () {
                                    if (isLiked) {
                                      dislikePost(context, postId);
                                    } else {
                                      likePost(context, postId);
                                    }
                                  },
                                ),
                                const SizedBox(width: 5),
                                Text('$likeCount', style: TextStyle(color: Colors.brown[800])),
                                const SizedBox(width: 90),
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
                                          postId: postId,
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
                                Text('$commentCount', style: TextStyle(color: Colors.brown[800])),
                                const SizedBox(width: 90),
                                IconButton(
                                  icon: Icon(
                                    Icons.bookmark,
                                    color: isBookmarked ? Colors.brown[300] : Colors.grey,
                                  ),
                                  onPressed: () {
                                    _bookmarkProvider.toggleBookmark(postId);
                                  },
                                ),
                              ],
                            ),
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
    );
  }
}