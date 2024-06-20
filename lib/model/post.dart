import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String? authorName;
  String? content;
  String? id;
  String? title;
  Timestamp? timestamp;

  Post({
    this.authorName,
    this.content,
    this.title,
    this.timestamp,
  });

  Post.fromJson(Map<String, dynamic> json) {
    authorName = json['authorName'];
    content = json['content'];
    title = json['title'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['authorName'] = authorName;
    data['content'] = content;
    data['title'] = title;
    data['timestamp'] = timestamp;
    return data;
  }
}
