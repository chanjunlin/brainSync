import 'package:brainsync/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChat {
  String? createdBy;
  String? groupID;
  String? groupName;
  List<String>? participantsID;
  List<Message>? messages;
  Message? lastMessage;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  int? unreadCount;

  GroupChat({
    required this.groupID,
    required this.groupName,
    required this.participantsID,
    this.createdBy,
    this.messages,
    this.lastMessage,
    this.createdAt,
    this.updatedAt,
    this.unreadCount,
  });

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      createdBy: json['createdBy'],
      groupID: json['id'],
      groupName: json["groupName"],
      participantsID: List<String>.from(json['participantsID']),
      messages: json['messages'] != null
          ? List.from(json['messages']).map((m) => Message.fromJson(m)).toList()
          : [],
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'])
          : null,
      createdAt: json['createdAt'] != null
          ? Timestamp.fromMillisecondsSinceEpoch(
              json['createdAt'].millisecondsSinceEpoch)
          : null,
      updatedAt: json['updatedAt'] != null
          ? Timestamp.fromMillisecondsSinceEpoch(
              json['updatedAt'].millisecondsSinceEpoch)
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'createdBy': createdBy,
      'id': groupID,
      'groupName': groupName,
      'participantsID': participantsID,
      'messages': messages?.map((m) => m.toJson()).toList() ?? [],
      'lastMessage': lastMessage?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'unreadCount': unreadCount ?? 0,
    };
    return data;
  }
}
