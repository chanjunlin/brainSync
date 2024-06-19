import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:badword_guard/badword_guard.dart';

import '../../services/auth_service.dart';
import '../Profile/visiting_profile.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  final String title;
  final String content;
  final DateTime timestamp;
  final String authorName;

  const PostDetailPage({
    Key? key,
    required this.postId,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.authorName,
  }) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {

  final GetIt _getIt = GetIt.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  late AuthService _authService;
  late DatabaseService _databaseService;
  late AlertService _alertService;

  String? currentUser;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    loadProfile();
  }

  final TextEditingController _commentController = TextEditingController();
  final LanguageChecker _checker = LanguageChecker();

  void loadProfile() async {
    final user = await _databaseService.fetchCurrentUser();
    final postUser = await _databaseService.fetchUser(widget.authorName);

    setState(() {
      currentUser = user!.id == widget.authorName
          ? "Me"
          : "${postUser!.get("firstName")} ${postUser.get("lastName")}";
    });
  }

  Future<void> addComment() async {
    if (_commentController.text.isNotEmpty) {
      if (_checker.containsBadLanguage(_commentController.text)) {
        _alertService.showToast(
          text: "Comment contains inappropriate content!",
          icon: Icons.error,
        );
        return;
      }

      String filteredComment = _checker.filterBadWords(_commentController.text); //comment saved under filtered comment

      final user = await _databaseService.fetchCurrentUser();
      final userId = user!.get("uid");

      final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }

      transaction.update(postRef, {
        'commentCount': FieldValue.increment(1),
      });

      transaction.set(
        postRef.collection('comments').doc(),
        {
          'content': filteredComment,
          'timestamp': Timestamp.now(),
          'authorId': userId,
          'likes': [],
        },
      );
    });

    _commentController.clear();
  }
}

Future<void> likeComment(BuildContext context, String postId, String commentId, String userId) async {
  try {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .update({
      'likes': FieldValue.arrayUnion([userId])
    });
  } on FirebaseException {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error liking comment'))
    );
  }
}

Future<void> dislikeComment(BuildContext context, String postId, String commentId, String userId) async {
  try {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .update({
      'likes': FieldValue.arrayRemove([userId])
    });
  } on FirebaseException {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error disliking comment'))
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
          'Post Details',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800]),
            ),
            const SizedBox(height: 10),
            Text(
              'By ${currentUser ?? "Loading..."}',
              style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.brown[800]),
            ),
            const SizedBox(height: 10),
            Text(
              widget.content,
              style: TextStyle(fontSize: 16, color: Colors.brown[800]),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              'Comments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown[800],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('comments')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  final comments = snapshot.data?.docs ?? [];
                  if (comments.isEmpty) {
                    return const Center(child: Text('No comments yet.'));
                  }

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment =
                      comments[index].data() as Map<String, dynamic>;
                      final timestamp = comment['timestamp'] as Timestamp;
                      final date = timestamp.toDate();
                      final formattedDate =
                      timeago.format(date, locale: 'custom');
                      final authorId = comment['authorId'] as String;
                      final likes = comment['likes'] ?? [];
                      final isLiked = likes.contains(userId);
                      final likeCount = likes.length;

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(authorId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListTile(
                              title: const Text('Loading...'),
                              subtitle: Text(comment['content']),
                            );
                          }
                          if (userSnapshot.hasError || !userSnapshot.hasData) {
                            return ListTile(
                              title: const Text('Error loading user'),
                              subtitle: Text(comment['content']),
                            );
                          }

                          final userData =
                          userSnapshot.data!.data() as Map<String, dynamic>;
                          final authorName =
                              "${userData['firstName']} ${userData['lastName']}";

                          return GestureDetector(
                            onTap: authorId == _authService.currentUser!.uid
                                ? null
                                : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VisitProfile(userId: authorId),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.brown[50],
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Colors.brown.shade200,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        authorId == _authService.currentUser!.uid
                                            ? "Me"
                                            : authorName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown[800],
                                        ),
                                      ),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.brown[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment['content'],
                                    style: TextStyle(color: Colors.brown[700]),
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: Icon(
                                        Icons.reply,
                                        color: Colors.brown[300],
                                      ),
                                      label: Text('Reply', style: TextStyle(
                                        color: Colors.black,
                                      ),),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                        color: isLiked ? Colors.brown[300] : Colors.grey,
                                      ),
                                      onPressed: () {
                                        if (isLiked) {
                                          dislikeComment(context, widget.postId, comments[index].id, userId);
                                        } else {
                                          likeComment(context,  widget.postId, comments[index].id, userId);
                                        }
                                      },
                                    ),
                                    Text('$likeCount'),
                                  ],
                                ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: addComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
