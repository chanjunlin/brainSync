import 'package:brainsync/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

class ShowMyPosts extends StatefulWidget {
  final List<String?>? myPosts;

  const ShowMyPosts({
    Key? key,
    required this.myPosts,
  }) : super(key: key);

  @override
  State<ShowMyPosts> createState() => _ShowMyPostsState();
}

class _ShowMyPostsState extends State<ShowMyPosts> {
  final GetIt _getIt = GetIt.instance;

  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.myPosts?.length ?? 0,
      itemBuilder: (context, index) {
        String? postId = widget.myPosts![index];
        print(postId);
        return FutureBuilder<DocumentSnapshot>(
          future: _databaseService.fetchPost(postId!), // Assume _databaseService.fetchPost fetches a single post by ID
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('Post not found');
            }

            // Replace with your Post model class or use Map<String, dynamic>
            var postData = snapshot.data!.data() as Map<String, dynamic>;

            // Example assuming Post model exists
            // Post post = Post.fromJson(postData);

            // Example without Post model
            String? authorName = postData['authorName'];
            String? title = postData['title'];
            String? content = postData['content'];

            return ListTile(
              title: Text(title ?? ''),
              subtitle: Text(content ?? ''),
              // Additional fields and styling as needed
            );
          },
        );
      },
    );
  }
}
