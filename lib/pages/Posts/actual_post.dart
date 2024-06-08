import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/auth_service.dart';
import '../Profile/visiting_profile.dart';
import 'comment_card.dart';

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

  late AuthService _authService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;

  String? currentUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
    loadProfile();
  }

  final TextEditingController _commentController = TextEditingController();

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
      final user = await _databaseService.fetchCurrentUser();
      final userId = user!.get("uid");

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'content': _commentController.text,
        'timestamp': Timestamp.now(),
        'authorId': userId, // Only store the user ID
      });
      _commentController.clear();
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown[800]),
            ),
            const SizedBox(height: 10),
            Text(
<<<<<<< HEAD:lib/pages/Posts/actual_post.dart
              'By ${currentUser ?? "Loading..."}',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
=======
              'By ${currentUser}',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.brown[800]),
>>>>>>> master:lib/pages/actual_post.dart
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
              style: TextStyle(fontSize: 18, 
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
                      final comment = comments[index].data() as Map<String, dynamic>;
                      final timestamp = comment['timestamp'] as Timestamp;
                      final date = timestamp.toDate();
<<<<<<< HEAD:lib/pages/Posts/actual_post.dart
                      final formattedDate = timeago.format(date, locale: 'custom');
                      final authorId = comment['authorId'] as String;

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(authorId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
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

                          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                          final authorName = "${userData['firstName']} ${userData['lastName']}";

                          return GestureDetector(
                            onTap: authorId == _authService.currentUser!.uid
                                ? null
                                : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VisitProfile(
                                    userId: authorId,
                                  ),
                                ),
                              );
                            },
                            child: CommentCard(
                              authorName: authorId == _authService.currentUser!.uid
                                  ? "Me"
                                  : authorName,
                              content: comment['content'],
                              formattedDate: formattedDate,
                            ),
                          );
                        },
=======
                      final formattedDate =
                          timeago.format(date, locale: 'custom');
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Card(
                          color: Colors.white,
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.brown,
                              width: 1.0,
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                          child: ListTile(
                            title: Text(
                              '${comment['authorName'] == '${user!.get('firstName')} ${user!.get('lastName')}' ? "Me" : comment['authorName']} $formattedDate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.brown[800],
                              )),
                          subtitle: Text(comment['content'],
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.brown[800],
                              )),
                        ),
                        ),
>>>>>>> master:lib/pages/actual_post.dart
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
