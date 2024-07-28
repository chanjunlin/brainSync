import 'dart:core';

import 'package:brainsync/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../model/post.dart';
import '../model/time.dart';
import '../pages/Posts/actual_post.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';

class HomePostCard extends StatefulWidget {
  final String? postId;

  const HomePostCard({
    super.key,
    required this.postId,
  });

  @override
  State<HomePostCard> createState() => _HomePostCardState();
}

class _HomePostCardState extends State<HomePostCard> {
  final GetIt _getIt = GetIt.instance;

  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;

  bool? isLiked, isBookmarked;
  DateTime? timeStamp;
  int? commentCount, likeCount;
  String? title, content, authorName, postId, timeAgo;
  List<dynamic>? bookmarks;
  List<dynamic>? likes;
  Future<void>? loadedProfile;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    loadedProfile = loadProfile();
    timeago.setLocaleMessages('custom', CustomShortMessages());
  }

  @override
  void dispose() {
    loadedProfile = null;
    super.dispose();
  }

  Future<void> loadProfile() async {
    try {
      DocumentSnapshot? userProfile = await _databaseService.fetchCurrentUser();
      DocumentSnapshot? postSnapshot =
      await _databaseService.fetchPost(widget.postId!);
      Post postData = postSnapshot.data() as Post;
      if (userProfile != null && userProfile.exists) {
        if (mounted) {
          setState(() {
            bookmarks = userProfile.get('bookmarks') ?? [];
            likes = userProfile.get('myLikedPosts') ?? [];
            isBookmarked = bookmarks!.contains(postData.id);
            isLiked = likes!.contains(postData.id);
            commentCount = postData.commentCount;
            title = postData.title;
            content = postData.content;
            postId = postData.id;
            authorName = postData.authorName;
            timeStamp = postData.timestamp?.toDate();
            timeAgo = timeStamp != null
                ? timeago.format(timeStamp!, locale: "custom")
                : "Unknown";
            likeCount = postData.likes?.length;
            commentCount = postData.commentCount ?? 0;
            isLiked = postData.likes?.contains(_authService.currentUser!.uid);
            isBookmarked = bookmarks!.contains(postData.id);
          });
        }
      } else {
        _alertService.showToast(text: 'User profile not found');
      }
    } catch (e) {
      _alertService.showToast(text: 'Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: loadedProfile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return buildCard();
        }
      },
    );
  }

  Widget buildCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.brown[800]!,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 5,
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0),
        onTap: () async {
          String result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailPage(
                postId: postId!,
                title: title!,
                timestamp: timeStamp!,
                content: content!,
                authorName: authorName!,
              ),
            ),
          );
          if (result == "refresh") {
            loadedProfile = loadProfile();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title!,
                      style: TextStyle(
                        color: Colors.brown[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "$timeAgo",
                    style: TextStyle(
                      color: Colors.brown[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                content!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.brown[700],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isLiked != null)
                        IconButton(
                          icon: Icon(
                            isLiked! ? Icons.thumb_up : Icons.thumb_up_outlined,
                            color: isLiked!
                                ? Colors.brown[300]
                                : Colors.brown[300],
                          ),
                          onPressed: () async {
                            if (isLiked!) {
                              dislikePost(postId!);
                            } else {
                              likePost(postId!);
                            }
                            if (mounted) {
                              setState(() {
                                isLiked = !isLiked!;
                                isLiked!
                                    ? likeCount = (likeCount ?? 0) + 1
                                    : likeCount = (likeCount ?? 0) - 1;
                              });
                            }
                          },
                        ),
                      if (isLiked != null)
                        Text(
                          '$likeCount',
                          style: TextStyle(
                            color: Colors.brown[700],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
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
                postId: postId!,
                title: title!,
                timestamp: timeStamp!,
                content: content!,
                authorName: authorName!,
              ),
            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 5),
                                      Text('$commentCount',
                                          style:
                                              TextStyle(color: Colors.brown[800])),
                                    ],
                  ),
                  Row(
                    children: [
                      if (isBookmarked != null)
                        IconButton(
                          icon: Icon(
                            isBookmarked!
                                ? Icons.bookmark
                                : Icons.bookmark_add_outlined,
                            color: isBookmarked!
                                ? Colors.brown[300]
                                : Colors.brown[300],
                          ),
                          onPressed: () async {
                            bookmark(postId!, isBookmarked!);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void likePost(String postId) async {
    await _databaseService.likePost(postId);
  }

  void dislikePost(String postId) async {
    await _databaseService.dislikePost(postId);
  }

  Future<void> bookmark(String postId, bool isBookmark) async {
    try {
      if (!isBookmark) {
        await _databaseService.addBookmark(postId);
      } else {
        await _databaseService.removeBookmark(postId);
      }
      if (mounted) {
        setState(() {
          isBookmarked = !isBookmark;
        });
      }
    } catch (e) {
      _alertService.showToast(
        text: "Error bookmarking post",
        icon: Icons.error,
      );
    }
  }
}
