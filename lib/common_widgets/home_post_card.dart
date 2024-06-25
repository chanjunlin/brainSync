import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../model/post.dart';
import '../pages/Posts/actual_post.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class PostCard extends StatefulWidget {
  final String postId;
  final Post postData;
  final bool isBookmark;

  const PostCard({
    super.key,
    required this.postId,
    required this.postData,
    required this.isBookmark,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final GetIt _getIt = GetIt.instance;

  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;

  late DateTime date;
  late String title;
  late String content;
  late String authorName;
  late String formattedDate;
  late Timestamp? timestamp;
  late int likeCount;
  late int commentCount;
  late bool isLiked;
  late bool isBookmarked;
  late List<String?> likes;
  late List<dynamic> userBookmarks;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    title = widget.postData.title ?? 'No Title';
    content = widget.postData.content ?? 'No Content';
    authorName = widget.postData.authorName ?? 'Unknown Author';
    timestamp = widget.postData.timestamp;
    date = timestamp!.toDate();
    formattedDate = timeago.format(date, locale: 'custom');
    likes = widget.postData.likes ?? [];
    likeCount = likes.length;
    commentCount = widget.postData.commentCount ?? 0;
    isLiked = likes.contains(_authService.currentUser!.uid);
    isBookmarked = widget.isBookmark;
  }

  @override
  Widget build(BuildContext context) {
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailPage(
                postId: widget.postId,
                title: title,
                timestamp: date,
                content: content,
                authorName: authorName,
              ),
            ),
          );
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
                      title,
                      style: TextStyle(
                        color: Colors.brown[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.brown[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                content,
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
                      IconButton(
                        icon: Icon(
                          isLiked! ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: isLiked! ? Colors.brown[300] : Colors.grey,
                        ),
                        onPressed: () async {
                          if (isLiked!) {
                            dislikePost(widget.postId);
                          } else {
                            likePost(widget.postId);
                          }
                          setState(() {
                            isLiked = !isLiked!;
                            if (isLiked!) {
                              likeCount = (likeCount ?? 0) + 1;
                              if (likes != null) {
                                likes!.add(_authService.currentUser!.uid);
                              } else {
                                likes = [_authService.currentUser!.uid];
                              }
                            } else {
                              likeCount = (likeCount ?? 0) - 1;
                              if (likes != null) {
                                likes!.remove(_authService.currentUser!.uid);
                              }
                            }
                          });
                        },
                      ),
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
                                postId: widget.postId,
                                title: title,
                                timestamp: date,
                                content: content,
                                authorName: authorName,
                              ),
                            ),
                          );
                        },
                      ),
                      Text(
                        '$commentCount',
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
                        icon: Icon(
                          isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_add_outlined,
                          color: isLiked ? Colors.brown[300] : Colors.grey,
                        ),
                        onPressed: () async {
                          bookmark(widget.postId, isBookmarked);
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
      setState(() {
        isBookmarked = !isBookmark;
      });
    } catch (e) {
      _alertService.showToast(
        text: "Error bookmarking post",
        icon: Icons.error,
      );
    }
  }
}
