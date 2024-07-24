import 'dart:core';
import 'dart:io';

import 'package:brainsync/model/message.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../model/group_chat.dart';
import '../../services/auth_service.dart';
import '../../services/media_service.dart';
import '../../services/navigation_service.dart';

class GroupChatPage extends StatefulWidget {
  final String groupID;
  final String groupName;

  const GroupChatPage({
    super.key,
    required this.groupID,
    required this.groupName,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late StorageService _storageService;

  late String groupName;
  ChatUser? currentUser, otherChatUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _storageService = _getIt.get<StorageService>();
    initializeGroupChat();
  }

  void initializeGroupChat() async {
    DocumentSnapshot<Object?> groupChatDetails =
        await _databaseService.getGroupChatDetails(widget.groupID);
    groupName = groupChatDetails.get("groupName");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        title: header(),
      ),
      body: buildUI(),
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0),
      child: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
          //   const CircleAvatar(
          //   radius: 24,
          //   backgroundImage: NetworkImage(''),
          // ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.groupName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUI() {
    return StreamBuilder(
      stream: _databaseService.getGroupChatData(
        widget.groupID
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading chat'));
        }
        GroupChat? groupChat = snapshot.data?.data();
        List<ChatMessage> messages = [];
        if (groupChat != null && groupChat.messages != null) {
          messages = _generateChatMessagesList(groupChat.messages!);
        }
        return DashChat(
          messageOptions: MessageOptions(
            currentUserContainerColor: Colors.brown[400],
            containerColor: Colors.brown.shade100,
            showOtherUsersAvatar: true,
            showTime: true,
          ),
          inputOptions: InputOptions(
            alwaysShowSend: true,
            trailing: [mediaMessageButton()],
          ),
          currentUser: currentUser!,
          onSend: _sendMessage,
          messages: messages,
        );
      },
    );
  }


  Future<void> _sendMessage(ChatMessage chatMessage) async {
    try {
      if (chatMessage.medias?.isNotEmpty ?? false) {
        if (chatMessage.medias!.first.type == MediaType.image) {
          Message message = Message(
            senderID: chatMessage.user.id,
            content: chatMessage.medias!.first.url,
            messageType: MessageType.Image,
            sentAt: Timestamp.fromDate(chatMessage.createdAt),
          );
        }
      } else {
        Message message = Message(
          senderID: currentUser!.id,
          content: chatMessage.text.trim(),
          messageType: MessageType.Text,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  List<ChatMessage> _generateChatMessagesList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherChatUser!,
          createdAt: m.sentAt!.toDate(),
          medias: [
            ChatMedia(
              url: m.content!,
              fileName: "",
              type: MediaType.image,
            ),
          ],
        );
      } else {
        return ChatMessage(
          text: m.content!,
          user: m.senderID == currentUser!.id ? currentUser! : otherChatUser!,
          createdAt: m.sentAt!.toDate(),
        );
      }
    }).toList();
    chatMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return chatMessages;
  }

  Widget mediaMessageButton() {
    return IconButton(
      onPressed: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          await _uploadAndSendMediaMessage(file);
        }
      },
      icon: Icon(
        Icons.image,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _uploadAndSendMediaMessage(File file) async {
    try {} catch (e) {
      print('Error uploading media: $e');
    }
  }
}
