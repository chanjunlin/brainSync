import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../model/time.dart';
import '../../services/auth_service.dart';
import '../Posts/actual_post.dart';

class BookmarkedPosts extends StatefulWidget {
  const BookmarkedPosts({super.key});

  @override
  _BookmarkedPostsState createState() => _BookmarkedPostsState();
}

class _BookmarkedPostsState extends State<BookmarkedPosts> {
  late String userID;
  late AuthService _authService;
  final GetIt _getIt = GetIt.instance;

  final Map<String, bool> _bookmarks = {};

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    userID = _authService.currentUser!.uid;
    timeago.setLocaleMessages('custom', CustomShortMessages());
    loadBookmarks();
  }

  Future<void> likePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([userID])
      });
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error liking post')),
      );
    }
  }

  Future<void> dislikePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([userID])
      });
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error disliking post')),
      );
    }
  }

  Future<void> bookmark(String postId, bool isBookmark) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userID);

      if (isBookmark) {
        await userRef.update({
          'bookmarks': FieldValue.arrayRemove([postId])
        });
      } else {
        await userRef.update({
          'bookmarks': FieldValue.arrayUnion([postId])
        });
      }

      setState(() {
        _bookmarks[postId] = !isBookmark;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error bookmarking post')),
      );
    }
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
          for (var postId in bookmarks) {
            _bookmarks[postId] = true;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading bookmarks')),
      );
    }
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
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text('No saved posts'));
          }

          final userDoc = userSnapshot.data!;
          List<String> bookmarks =
              List<String>.from(userDoc['bookmarks'] ?? []);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .where(FieldPath.documentId, whereIn: bookmarks)
                .snapshots(),
            builder: (context, postSnapshot) {
              if (postSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!postSnapshot.hasData || postSnapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/img/brain.png"),
                      const Text(
                        'The Silence Is Deafening',
                        style:
                            TextStyle(color: Color.fromARGB(255, 78, 52, 46)),
                      ),
                      SizedBox(width: 60),
                    ],
                  ),
                );
              }

              final bookmarkedPosts = postSnapshot.data!.docs;

              return ListView.builder(
                itemCount: bookmarkedPosts.length,
                itemBuilder: (context, index) {
                  final post =
                      bookmarkedPosts[index].data() as Map<String, dynamic>;
                  final postId = bookmarkedPosts[index].id;
                  final timestamp = post['timestamp'] as Timestamp;
                  final date = timestamp.toDate();
                  final formattedDate = timeago.format(date, locale: 'custom');
                  final likes = post['likes'] ?? [];
                  final isLiked = likes.contains(userID);
                  final likeCount = likes.length;
                  final commentCount = post['commentCount'] ?? 0;
                  final isBookmarked = _bookmarks[postId] ?? true;

                  return Card(
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.brown, width: 1.0),
                      borderRadius: BorderRadius.zero,
                    ),
                    margin: const EdgeInsets.all(0),
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
                                  style:
                                      TextStyle(color: Colors.brown.shade800),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              post['content'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15, color: Colors.brown[800]),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
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
                                    isLiked
                                        ? dislikePost(postId)
                                        : likePost(postId);
                                  },
                                ),
                                const SizedBox(width: 5),
                                Text('$likeCount',
                                    style: TextStyle(color: Colors.brown[800])),
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
                                Text('$commentCount',
                                    style: TextStyle(color: Colors.brown[800])),
                                const SizedBox(width: 90),
                                IconButton(
                                  icon: Icon(
                                    Icons.bookmark,
                                    color: Colors.brown[300],
                                  ),
                                  onPressed: () {
                                    bookmark(postId, isBookmarked);
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
