import 'dart:core';
import 'dart:io';

import 'package:brainsync/model/message.dart';
import 'package:brainsync/pages/Chats/friends_chat.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../const.dart';
import '../../../model/group_chat.dart';
import '../../../services/auth_service.dart';
import '../../../services/media_service.dart';
import '../../../services/navigation_service.dart';
import 'group_chat_details.dart';

class GroupChatPage extends StatefulWidget {
  final String groupID;
  final String groupName;
  final String groupPicture;

  const GroupChatPage({
    super.key,
    required this.groupID,
    required this.groupName,
    required this.groupPicture,
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
  ChatUser? currentUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _storageService = _getIt.get<StorageService>();
    initializeGroupChat();
    currentUser = ChatUser(
      id: _authService.currentUser!.uid,
      firstName: _authService.currentUser!.displayName,
    );
  }

  void initializeGroupChat() async {
    DocumentSnapshot? groupChatDetails =
    await _databaseService.getGroupChatDetails(widget.groupID);
    setState(() {
      groupName = groupChatDetails?.get("groupName");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        title: GestureDetector(
          child: header(),
          onTap: () {
            _navigationService.push(
              MaterialPageRoute(
                builder: (context) {
                  return GroupChatDetails(
                    groupID: widget.groupID,
                    groupName: widget.groupName,
                  );
                },
              ),
            );
          },
        ),
        leading: IconButton(
          onPressed: () {
            _navigationService.push(
              MaterialPageRoute(
                builder: (context) {
                  return const FriendsChats(tabNumber: 1);
                },
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: buildUI(),
    );
  }

  Widget buildUI() {
    return StreamBuilder(
      stream: _databaseService.getGroupChatData(widget.groupID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading chat'));
        }

        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return const Center(child: Text('No chat data found'));
        }

        GroupChat chat = snapshot.data!.data()!;

        return FutureBuilder<List<ChatMessage>>(
          future: generateChatMessagesList(chat.messages ?? []),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (futureSnapshot.hasError) {
              return const Center(child: Text('Error loading messages'));
            }

            List<ChatMessage> messages = futureSnapshot.data ?? [];

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
      },
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(widget.groupPicture ?? PLACEHOLDER_PFP),
          ),
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
        ],
      ),
    );
  }

  Future<void> sendMessage(ChatMessage chatMessage) async {
    try {
      if (chatMessage.medias?.isNotEmpty ?? false) {
        if (chatMessage.medias!.first.type == MediaType.image) {
          Message message = Message(
            senderID: chatMessage.user.id,
            content: chatMessage.medias!.first.url,
            messageType: MessageType.Image,
            sentAt: Timestamp.fromDate(chatMessage.createdAt),
          );
          await _databaseService.sendGroupChatMessage(
            widget.groupID,
            message,
          );
        }
      } else {
        Message message = Message(
          senderID: currentUser!.id,
          content: chatMessage.text.trim(),
          messageType: MessageType.Text,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );
        await _databaseService.sendGroupChatMessage(
          widget.groupID,
          message,
        );
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<List<ChatMessage>> generateChatMessagesList(
      List<Message> messages) async {
    final senderIDs = messages.map((m) => m.senderID!).toSet();
    final usernameFutures =
    senderIDs.map((id) => _authService.getUserName(id)).toList();
    final usernames = await Future.wait(usernameFutures);

    List<ChatMessage> chatMessages = messages.map((m) {
      final senderIndex = senderIDs.toList().indexOf(m.senderID!);
      final otherChatter = ChatUser(
        id: m.senderID!,
        firstName: usernames[senderIndex],
      );

      if (m.messageType == MessageType.Image) {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherChatter,
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
          user: m.senderID == currentUser!.id ? currentUser! : otherChatter,
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
        color: Theme
            .of(context)
            .colorScheme
            .primary,
      ),
    );
  }

  Future<void> uploadAndSendMediaMessage(File file) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_media')
          .child(DateTime
          .now()
          .millisecondsSinceEpoch
          .toString());
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      final mediaUrl = await snapshot.ref.getDownloadURL();

      final chatMessage = ChatMessage(
        user: currentUser!,
        createdAt: DateTime.now(),
        medias: [
          ChatMedia(
            url: mediaUrl,
            fileName: file.path
                .split('/')
                .last,
            type: MediaType.image,
          ),
        ],
      );
      sendMessage(chatMessage);
    } catch (e) {
      print('Error uploading media: $e');
    }
  }
}
