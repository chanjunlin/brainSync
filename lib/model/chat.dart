import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brainsync/model/message.dart';

class Chat {
  String? id;
  List<String>? participantsNames;
  List<String>? participantsIds;
  List<Message>? messages;
  Message? lastMessage;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  bool? isGroupChat;
  int? unreadCount;

  Chat({
    required this.id,
    required this.participantsIds,
    this.participantsNames,
    this.messages,
    this.lastMessage,
    this.createdAt,
    this.updatedAt,
    this.isGroupChat,
    this.unreadCount,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      participantsIds: List<String>.from(json['participantsIds']),
      participantsNames: List<String>.from(json['participantsNames']),
      messages: json['messages'] != null ? List.from(json['messages']).map((m) => Message.fromJson(m)).toList() : [],
      lastMessage: json['lastMessage'] != null ? Message.fromJson(json['lastMessage']) : null,
      createdAt: json['createdAt'] != null ? Timestamp.fromMillisecondsSinceEpoch(json['createdAt'].millisecondsSinceEpoch) : null,
      updatedAt: json['updatedAt'] != null ? Timestamp.fromMillisecondsSinceEpoch(json['updatedAt'].millisecondsSinceEpoch) : null,
      isGroupChat: json['isGroupChat'] ?? false,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'participantsIds': participantsIds,
      'participantsNames': participantsNames,
      'messages': messages?.map((m) => m.toJson()).toList() ?? [],
      'lastMessage': lastMessage?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isGroupChat': isGroupChat ?? false,
      'unreadCount': unreadCount ?? 0,
    };
    return data;
  }
}
