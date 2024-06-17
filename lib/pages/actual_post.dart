import 'dart:ffi';

import 'package:brainsync/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:badword_guard/badword_guard.dart';

import '../services/auth_service.dart';

class PostDetailPagetest extends StatefulWidget {
  final String postId;
  final String title;
  final String content;
  final DateTime timestamp;
  final String authorName;

  PostDetailPagetest({
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

class _PostDetailPageState extends State<PostDetailPagetest> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late DatabaseService _databaseService;
  late DocumentSnapshot? user, postUser;

  String? currentUser, commentUser;

  final LanguageChecker _languageChecker = LanguageChecker();
  @override
  void initState() {
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    loadProfile();
  }

  final TextEditingController _commentController = TextEditingController();

  void loadProfile() async {
    user = await _databaseService.fetchCurrentUser();
    postUser = await _databaseService.fetchUser(widget.authorName);

    if (user!.id == widget.authorName) {
      setState(() {
        currentUser = "Me";
      });
    } else {
      setState(() {
        currentUser =
            "${postUser!.get("firstName")} ${postUser!.get("lastName")}";
      });
    }
    commentUser = "${postUser!.get("firstName")} ${postUser!.get("lastName")}";
  }

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      DocumentSnapshot? user = await _databaseService.fetchCurrentUser();

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'content': _commentController.text,
        'timestamp': Timestamp.now(),
        'authorName': "${user!.get("firstName")} ${user!.get("lastName")}",
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
              'By ${currentUser}',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.brown[800]),
            ),
            const SizedBox(height: 10),
            Text(
              widget.content,
              style: TextStyle(fontSize: 16, color: Colors.brown[800]),
            ),
            const SizedBox(height: 20),
              Divider(
              color: Colors.brown[800],
            ),
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

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment =
                          comments[index].data() as Map<String, dynamic>;
                      final timestamp = comment['timestamp'] as Timestamp;
                      final date = timestamp.toDate();
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
                  onPressed: _addComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

