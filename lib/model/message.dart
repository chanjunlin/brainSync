import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message {
  String? senderID;
  String? content;
  String? key;
  MessageType? messageType;
  Timestamp? sentAt;

  Message({
    required this.senderID,
    required this.content,
    required this.messageType,
    required this.sentAt,
    this.key,
  });

  Message.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    senderID = json['senderID'];
    content = json['content'];
    sentAt = json['sentAt'] != null
        ? Timestamp.fromMillisecondsSinceEpoch(
            json['sentAt'].millisecondsSinceEpoch)
        : null;
    messageType = MessageType.values
        .firstWhere((type) => type.name == json['messageType']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['senderID'] = senderID;
    data['content'] = content;
    data['sentAt'] = sentAt;
    data['messageType'] = messageType!.name;
    return data;
  }
}
