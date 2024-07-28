import 'dart:core';
import 'dart:io';

import 'package:brainsync/model/chat.dart';
import 'package:brainsync/model/message.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/storage_service.dart';
import 'package:brainsync/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../model/user_profile.dart';
import '../../../services/auth_service.dart';
import '../../../services/media_service.dart';
import '../../../services/navigation_service.dart';
import '../../Profile/visiting_profile/visiting_profile.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;

  const ChatPage({
    super.key,
    required this.chatUser,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late StorageService _storageService;

  late UserProfile otherUser;
  ChatUser? currentUser, otherChatUser;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeUsers();
  }

  void _initializeServices() {
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _storageService = _getIt.get<StorageService>();
  }

  void _initializeUsers() {
    currentUser = ChatUser(
      id: _authService.currentUser!.uid,
      firstName: _authService.currentUser!.displayName,
    );
    otherUser = widget.chatUser;
    otherChatUser = ChatUser(id: otherUser.uid!);
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
      padding: const EdgeInsets.only(right: 5.0, top: 4.0, bottom: 10.0),
      child: GestureDetector(
          onTap: () {
            _navigationService.push(MaterialPageRoute(builder: (context) {
              return VisitProfile(userId: widget.chatUser.uid!);
            }));
          },
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(widget.chatUser.pfpURL ?? ''),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatUser.firstName ?? 'User',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (widget.chatUser.lastName != null)
                    Text(
                      widget.chatUser.lastName!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUI() {
    return StreamBuilder(
      stream: _databaseService.getChatData(
        currentUser!.id,
        otherUser.uid!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading chat'));
        }
        Chat? chat = snapshot.data?.data();
        List<ChatMessage> messages = [];
        if (chat != null && chat.messages != null) {
          messages = generateChatMessagesList(chat.messages!);
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
          onSend: sendMessage,
          messages: messages,
        );
      },
    );
  }

  Future<void> sendMessage(ChatMessage chatMessage) async {
    try {
      if (chatMessage.medias?.isNotEmpty ?? false) {
        if (chatMessage.medias!.first.type == MediaType.image) {
          Message message = Message(
            senderID: chatMessage.user.id,
            content: chatMessage.medias!.first.url,
            messageType: MessageType.image,
            sentAt: Timestamp.fromDate(chatMessage.createdAt),
          );
          await _databaseService.sendChatMessage(
            currentUser!.id,
            otherUser.uid!,
            message,
          );
        }
      } else {
        Message message = Message(
          senderID: currentUser!.id,
          content: chatMessage.text.trim(),
          messageType: MessageType.text,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );
        await _databaseService.sendChatMessage(
          currentUser!.id,
          otherUser.uid!,
          message,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
    }
  }

  List<ChatMessage> generateChatMessagesList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.image) {
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
          await uploadAndSendMediaMessage(file);
        }
      },
      icon: Icon(
        Icons.image,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> uploadAndSendMediaMessage(File file) async {
    try {
      String chatID = generateChatID(
        uid1: currentUser!.id,
        uid2: otherUser.uid!,
      );
      String? downloadURL = await _storageService.uploadImageToChat(
        file: file,
        chatID: chatID,
      );
      if (downloadURL != null) {
        ChatMessage chatMessage = ChatMessage(
          user: currentUser!,
          createdAt: DateTime.now(),
          medias: [
            ChatMedia(
              url: downloadURL,
              fileName: "",
              type: MediaType.image,
            ),
          ],
        );
        await sendMessage(chatMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading media: $e');
      }
    }
  }
}
