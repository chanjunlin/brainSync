import 'package:brainsync/common_widgets/home_post_card.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShowMyPosts extends StatefulWidget {
  final List<String?>? myPosts;

  const ShowMyPosts({
    super.key,
    required this.myPosts,
  });

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
    if (widget.myPosts == null || widget.myPosts!.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No posts found'),
        ),
      );
    } else {
      return Scaffold(
        body: FutureBuilder<QuerySnapshot>(
          future: _databaseService
              .fetchUserPosts(widget.myPosts!.whereType<String>().toList()),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No posts found'));
            }
            List<DocumentSnapshot> posts = snapshot.data!.docs;
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return HomePostCard(
                  postId: posts[index].id,
                );
              },
            );
          },
        ),
      );
    }
  }
}
