import 'dart:async';

import 'package:brainsync/model/user_profile.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../model/chat.dart';
import '../model/message.dart';
import 'auth_service.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;

  CollectionReference<UserProfile>? _usersCollection;
  CollectionReference? _chatCollection;

  late AlertService _alertService;
  late AuthService _authService;

  DatabaseService() {
    setUpCollectionReferences();
    _alertService = _getIt.get<AlertService>();
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

    }
  }

  Future<DocumentSnapshot?> fetchCurrentUser() async {
    try {
      String userId = _authService.currentUser!.uid;
      print(userId);
      return await _firebaseFirestore.collection('users').doc(userId).get();
    } catch (e) {
      // _alertService.showToast(text: "Error fetching user profile: $e");
      return null;
    }
  }

  Future<DocumentSnapshot?> fetchUser(String userID) async {
    try {
      return await _firebaseFirestore.collection('users').doc(userID).get();
    } catch (e) {
      // _alertService.showToast(text: "Error fetching user profile: $e");
      return null;
    }
  }

  Future<List<UserProfile?>> getFriends() async {
    DocumentSnapshot? userDocs = await fetchCurrentUser();
    List<UserProfile?> friends = [];
    if (userDocs != null && userDocs.exists) {
      Map<String, dynamic> userData = userDocs.data() as Map<String, dynamic>;
      List<dynamic> friendList = userData['friendList'] ?? [];
      for (String friendId in friendList) {
        DocumentSnapshot friendDoc =
        await _firebaseFirestore.collection('users').doc(friendId).get();
        if (friendDoc.exists) {
          friends.add(
              UserProfile.fromJson(friendDoc.data() as Map<String, dynamic>));
        }
      }
    } else {
      // _alertService.showToast(text: "User profile doesn't exists.");
    }
    return friends;
  }

  Future<List<UserProfile?>> getMutualFriends(
      String userId, String friendId) async {
    DocumentSnapshot? userDocs = await fetchUser(userId);
    DocumentSnapshot? friendDocs = await fetchUser(friendId);

    List<UserProfile?> commonFriends = [];

    if (userDocs != null &&
        userDocs.exists &&
        friendDocs != null &&
        friendDocs.exists) {
      Map<String, dynamic> userData = userDocs.data() as Map<String, dynamic>;
      Map<String, dynamic> friendData =
      friendDocs.data() as Map<String, dynamic>;

      List<dynamic> userFriendList = userData['friendList'] ?? [];
      List<dynamic> friendFriendList = friendData['friendList'] ?? [];

      for (String friendId in userFriendList) {
        if (friendFriendList.contains(friendId)) {
          DocumentSnapshot? mutualFriendDoc = await fetchUser(friendId);
          commonFriends.add(
              UserProfile.fromJson(mutualFriendDoc?.data() as Map<String, dynamic>));
        }
      }
    } else {
      // _alertService.showToast(text: "User profile doesn't exists.");
    }
    return commonFriends;
  }

  Stream<DocumentSnapshot<Object?>> getUserProfile(String uid) {
    return _firebaseFirestore.collection('users').doc(uid).snapshots();
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

  Future<void> sendFriendRequest(
      String senderUid, String receiverUid, Function(bool) callback) async {
    await _firebaseFirestore.collection('users').doc(receiverUid).update({
      'friendReqList': FieldValue.arrayUnion([senderUid])
    });
    callback(true);
  }

  Future<void> cancelFriendRequest(
      String senderUid, String receiverUid, Function(bool) callback) async {
    await _firebaseFirestore.collection('users').doc(receiverUid).update({
      'friendReqList': FieldValue.arrayRemove([senderUid])
    });
    callback(false);
  }

  Future<void> rejectFriendRequest(String receiverUid, String senderUid) async {
    await _firebaseFirestore.collection('users').doc(receiverUid).update({
      'friendReqList': FieldValue.arrayRemove([senderUid])
    });
  }

  Future<void> acceptFriendRequest(String senderUid, String receiverUid) async {
    DocumentReference senderDoc =
    _firebaseFirestore.collection('users').doc(senderUid);
    DocumentReference receiverDoc =
    _firebaseFirestore.collection('users').doc(receiverUid);

    await _firebaseFirestore.runTransaction((transaction) async {
      transaction.update(senderDoc, {
        'friendList': FieldValue.arrayUnion([receiverUid]),
        'friendReqList': FieldValue.arrayRemove([receiverUid])
      });

      transaction.update(receiverDoc, {
        'friendList': FieldValue.arrayUnion([senderUid]),
        'friendReqList': FieldValue.arrayRemove([senderUid])
      });
    });
  }

  Future<void> removeFriend(String userId, String receiverUid) async {
    try {
      DocumentSnapshot userDoc =
      await _firebaseFirestore.collection('users').doc(userId).get();
      DocumentSnapshot receiverDoc =
      await _firebaseFirestore.collection('users').doc(receiverUid).get();
      List<dynamic>? friendList = userDoc["friendList"];
      List<dynamic>? receiverFriendList = receiverDoc["friendList"];
      if (friendList != null && friendList.contains(receiverUid)) {
        friendList.remove(receiverUid);
        receiverFriendList?.remove(userId);
        await userDoc.reference.update({'friendList': friendList});
        await receiverDoc.reference.update({'friendList': friendList});
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateProfile(UserProfile user) async {
    await _firebaseFirestore
        .doc(_authService.currentUser!.uid)
        .update(user.toJson());
  }

  Future<void> addModuleToUserSchedule(String userId, String moduleCode) async {
    DocumentReference userDoc =
    _firebaseFirestore.collection('users').doc(userId);
    await userDoc.update({
      'currentModule': FieldValue.arrayUnion([moduleCode])
    });
  }

  Future<bool> isInCurrentModule(String userId, String moduleCode) async {
    try {
      DocumentSnapshot userDoc =
      await _firebaseFirestore.collection('users').doc(userId).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<String> currentModules =
      List<String>.from(userData['currentModule'] ?? []);
      return currentModules.contains(moduleCode);
    } catch (error) {
      print("Error checking current module: $error");
      return false; // Return false in case of an error
    }
  }

  Future<bool> isInCompletedModule(String userId, String moduleCode) async {
    try {
      DocumentSnapshot userDoc =
      await _firebaseFirestore.collection('users').doc(userId).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<String> computedModules =
      List<String>.from(userData['completedModule'] ?? []);
      return computedModules.contains(moduleCode);
    } catch (error) {
      print("Error checking current module: $error");
      return false;
    }
  }

  Future<void> removeModule(String userId, String moduleCode) async {
    try {
      DocumentSnapshot userDoc =
      await _firebaseFirestore.collection('users').doc(userId).get();
      List<dynamic>? currentModules = userDoc["currentModule"];
      if (currentModules != null && currentModules.contains(moduleCode)) {
        currentModules.remove(moduleCode);
        await userDoc.reference.update({'currentModule': currentModules});
      }
    } catch (e) {
      print(e);
    }
  }
}