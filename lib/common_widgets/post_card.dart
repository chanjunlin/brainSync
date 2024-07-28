import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../pages/Posts/actual_post.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class PostCard extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> postData;
  final VoidCallback onLikeChanged;

  const PostCard({
    super.key,
    required this.postId,
    required this.postData,
    required this.onLikeChanged,
  });

  @override
  PostCardState createState() => PostCardState();
}

class PostCardState extends State<PostCard> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.postData['title'];
    String content = widget.postData['content'];
    String authorName = widget.postData['authorName'];
    Timestamp timestamp = widget.postData['timestamp'];
    DateTime date = timestamp.toDate();
    String formattedDate = timeago.format(date, locale: 'custom');
    List<dynamic> likes = widget.postData['likes'] ?? [];
    int likeCount = likes.length;
    int commentCount = widget.postData['commentCount'] ?? 0;
    bool isLiked = likes.contains(_authService.currentUser!.uid);

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
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: isLiked ? Colors.brown[300] : Colors.grey,
                        ),
                        onPressed: () async {
                          if (isLiked) {
                            await _databaseService.dislikePost(widget.postId);
                          } else {
                            await _databaseService.likePost(widget.postId);
                          }
                          widget.onLikeChanged();
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
