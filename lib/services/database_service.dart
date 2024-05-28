import 'dart:async';

import 'package:brainsync/auth.dart';
import 'package:brainsync/model/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:brainsync/utils.dart';

import '../model/chat.dart';
import '../model/message.dart';
import 'auth_service.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;

  CollectionReference<UserProfile>? _usersCollection;
  CollectionReference? _chatCollection;

  late AuthService _authService;

  DatabaseService() {
    setUpCollectionReferences();
    _authService = _getIt.get<AuthService>();
  }

  void setUpCollectionReferences() {
    _usersCollection =
        _firebaseFirestore.collection('users').withConverter<UserProfile>(
              fromFirestore: (snapshots, _) =>
                  UserProfile.fromJson(snapshots.data()!),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );
    _chatCollection = _firebaseFirestore
        .collection('chats')
        .withConverter<Chat>(
            fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
            toFirestore: (chat, _) => chat.toJson());
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    try {
      await _usersCollection?.doc(userProfile.uid).set(userProfile);
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  Future<DocumentSnapshot?> fetchUser() async {
    try {
      String userId = _authService.user!.uid;
      return await _firebaseFirestore.collection('users').doc(userId).get();
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  Future<DocumentSnapshot<Object?>> getUserProfile(String uid) async {
    return await _firebaseFirestore.collection('users').doc(uid).get();
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _usersCollection
        ?.where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExist(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final result = await _chatCollection?.doc(chatID).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatID);
    final chat = Chat(id: chatID, participants: [uid1, uid2], messages: []);
    await docRef.set(chat);
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatID);
    await docRef.update({
      "messages": FieldValue.arrayUnion([
        message.toJson(),
      ])
    });
  }

  Stream getChatData(String uid1, String uid2) {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatID);
    return docRef.snapshots() as Stream<DocumentSnapshot<Chat>>;
  }

  Future<void> sendFriendRequest(String senderUid, String receiverUid) async {
    await _firebaseFirestore.collection('users').doc(receiverUid).update({
      'friendReqList': FieldValue.arrayUnion([senderUid])
    });
  }

  Future<void> rejectFriendRequest(String receiverUid, String senderUid) async {
    await _firebaseFirestore.collection('users').doc(receiverUid).update({
      'friendReqList': FieldValue.arrayRemove([senderUid])
    });
  }

  Future<void> acceptFriendRequest(String senderUid, String receiverUid) async {
    DocumentReference senderDoc = _firebaseFirestore.collection('users').doc(senderUid);
    DocumentReference receiverDoc = _firebaseFirestore.collection('users').doc(receiverUid);

    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentSnapshot senderSnapshot = await transaction.get(senderDoc);
      DocumentSnapshot receiverSnapshot = await transaction.get(receiverDoc);

      transaction.update(senderDoc, {
        'friendList': FieldValue.arrayUnion([receiverUid])
      });

      transaction.update(receiverDoc, {
        'friendList': FieldValue.arrayUnion([senderUid]),
        'friendReqList': FieldValue.arrayRemove([senderUid])
      });
    });
  }
}
