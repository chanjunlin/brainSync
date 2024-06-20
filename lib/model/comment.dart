import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String? authorID;
  String? content;

  List<String?>? likes;

  Timestamp? timestamp;

  Comment({
    required this.authorID,
    required this.content,
    required this.likes,
    required this.timestamp,
  });

  Comment.fromJson(Map<String, dynamic> json) {
    authorID = json['authorId'];
    content = json['content'];
    likes = json['likes'] != null ? List<String>.from(json['likes']) : [];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['authorId'] = authorID;
    data['content'] = content;
    data['likes'] = likes;
    data['timestamp'] = timestamp;
    return data;
  }
}
