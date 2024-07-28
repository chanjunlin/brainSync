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
    final Size screenSize = MediaQuery.of(context).size;

    Widget buildNoPostsContent() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/img/sad_brain.png",
              height: screenSize.height * 0.3,
              width: screenSize.width * 0.5,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            const Text(
              'No posts made',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: widget.myPosts == null || widget.myPosts!.isEmpty
          ? buildNoPostsContent()
          : FutureBuilder<QuerySnapshot>(
        future: _databaseService.fetchUserPosts(widget.myPosts!.whereType<String>().toList()),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return buildNoPostsContent();
          }

          List<DocumentSnapshot> posts = snapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
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
