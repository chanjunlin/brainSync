
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  int? commentCount;

  List<dynamic>? likes;

  String? authorName;
  String? content;
  String? id;
  String? title;
  Timestamp? timestamp;



  Post({
    this.commentCount,
    this.likes,
    this.authorName,
    this.content,
    this.id,
    this.title,
    this.timestamp,
  });

  Post.fromJson(Map<String, dynamic> json) {
    commentCount = json['commentCount'] ?? 0;
    likes = json['likes'] != null ? List<String>.from(json['likes']) : [];
    authorName = json['authorName'];
    content = json['content'];
    id = json['id'];
    title = json['title'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['commentCount'];
    data['likes'];
    data['authorName'] = authorName;
    data['content'] = content;
    data['title'] = title;
    data['timestamp'] = timestamp;
    return data;
  }
}
