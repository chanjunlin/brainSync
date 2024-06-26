import 'dart:core';

import 'package:brainsync/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../model/post.dart';
import '../pages/Posts/actual_post.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';

class HomePostCard extends StatefulWidget {
  bool? isBookmark;
  bool? isLiked;

  DateTime? timeStamp;

  int? commentCount;
  int? likeCount;

  Post? postData;

  String? authorName;
  String? content;
  String? postId;
  String? title;

  List<dynamic>? likes;
  List<dynamic>? userBookmarks;

  HomePostCard({
    super.key,
    required this.isBookmark,
    required this.isLiked,
    required this.postData,
    required this.authorName,
    required this.commentCount,
    required this.content,
    required this.likeCount,
    required this.postId,
    required this.timeStamp,
    required this.title,
    required this.likes,
    required this.userBookmarks,
  });

  @override
  State<HomePostCard> createState() => _HomePostCardState();
}

class _HomePostCardState extends State<HomePostCard> {
  final GetIt _getIt = GetIt.instance;

  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;

  late bool isLiked;
  late bool isBookmarked;
  late String formattedDate;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    isLiked = widget.isLiked!;
    isBookmarked = widget.isBookmark!;
    formattedDate = timeago.format(widget.timeStamp!, locale: 'custom');
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
                postId: widget.postId!,
                title: widget.title!,
                timestamp: widget.timeStamp!,
                content: widget.content!,
                authorName: widget.authorName!,
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
                      widget.title!,
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
                widget.content!,
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
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: isLiked ? Colors.brown[300] : Colors.grey,
                        ),
                        onPressed: () async {
                          if (isLiked) {
                            dislikePost(widget.postId!);
                          } else {
                            likePost(widget.postId!);
                          }
                          setState(() {
                            isLiked = !isLiked;
                            if (isLiked) {
                              widget.likeCount = (widget.likeCount ?? 0) + 1;
                              if (widget.likes != null) {
                                widget.likes!
                                    .add(_authService.currentUser!.uid);
                              } else {
                                widget.likes = [_authService.currentUser!.uid];
                              }
                            } else {
                              widget.likeCount = (widget.likeCount ?? 0) - 1;
                              if (widget.likes != null) {
                                widget.likes!
                                    .remove(_authService.currentUser!.uid);
                              }
                            }
                          });
                        },
                      ),
                      Text(
                        '${widget.likeCount}',
                        style: TextStyle(
                          color: Colors.brown[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.comment,
                        color: Color.fromARGB(255, 161, 136, 127),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${widget.commentCount!}',
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
                          color:
                              isLiked ? Colors.brown[300] : Colors.brown[300],
                        ),
                        onPressed: () async {
                          bookmark(widget.postId!, isBookmarked);
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
