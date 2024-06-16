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

  // Setting up all collections
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

  // Create a new user
  Future<void> createUserProfile({required UserProfile userProfile}) async {
    try {
      await _usersCollection?.doc(userProfile.uid).set(userProfile);
    } catch (e) {
      _alertService.showToast(text: "Error creating user profile: $e");
    }
  }

  // Update user profile
  Future<void> updateProfile(UserProfile user) async {
    await _firebaseFirestore
        .doc(_authService.currentUser!.uid)
        .update(user.toJson());
  }

  // Fetch the current user's docs
  Future<DocumentSnapshot?> fetchCurrentUser() async {
    try {
      String userId = _authService.currentUser!.uid;
      return await _firebaseFirestore.collection('users').doc(userId).get();
    } catch (e) {
      _alertService.showToast(text: "Error fetching user profile: $e");
      return null;
    }
  }

  // Fetch the specific user's docs
  Future<DocumentSnapshot?> fetchUser(String userID) async {
    try {
      return await _firebaseFirestore.collection('users').doc(userID).get();
    } catch (e) {
      _alertService.showToast(text: "Error fetching user profile: $e");
      return null;
    }
  }

  // Fetch the specific user's UserProfile
  Future<UserProfile> fetchUserProfile(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firebaseFirestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        return UserProfile.fromJson(snapshot.data() as Map<String, dynamic>);
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      throw Exception("Error");
    }
  }

  Stream<DocumentSnapshot<Object?>> getUserProfile(String uid) {
    return _firebaseFirestore.collection('users').doc(uid).snapshots();
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _usersCollection
        ?.where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  // CHAT METHODS

  // Checking if chat exists
  Future<bool> checkChatExist(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final result = await _chatCollection?.doc(chatID).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  // Creating a new chat if the chat doesnt exists
  Future<void> createNewChat(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatID);
    DocumentSnapshot? user1Docs = await fetchUser(uid1);
    DocumentSnapshot? user2Docs = await fetchUser(uid2);
    String user1Name = user1Docs?["firstName"] + " " + user1Docs?["lastName"];
    String user2Name = user2Docs?["firstName"] + " " + user2Docs?["lastName"];
    final chat = Chat(
      id: chatID,
      participantsIds: [uid1, uid2],
      messages: [],
      participantsNames: [user1Name, user2Name],
    );
    await docRef.set(chat);
  }

  // Retrieve chat details in DocumentSnapshot
  Future<DocumentSnapshot<Object?>> getChatDetails(String chatId) async {
    return _firebaseFirestore.collection('chats').doc(chatId).get();
  }

  // Retrieve all chats from user
  Stream<QuerySnapshot> getAllUserChatsStream() {
    return _firebaseFirestore
        .collection('chats')
        .where('participantsIds', arrayContains: _authService.currentUser!.uid)
        .snapshots();
  }

  // Send chat message
  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = FirebaseFirestore.instance.collection('chats').doc(chatID);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot user1Snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid1)
            .get();
        DocumentSnapshot user2Snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid2)
            .get();
        DocumentSnapshot chatSnapshot = await transaction.get(docRef);
        DocumentSnapshot docSnapshot = await docRef.get();
        Map<String, dynamic> chatData =
            docSnapshot.data() as Map<String, dynamic>;
        print(chatData["messages"]);
        List<dynamic> user1Chats = user1Snapshot.get('chats') ?? [];
        List<dynamic> user2Chats = user2Snapshot.get('chats') ?? [];

        if (!user1Chats.contains(chatID)) {
          transaction.update(user1Snapshot.reference, {
            'chats': FieldValue.arrayUnion([chatID]),
          });
        }

        if (!user2Chats.contains(chatID)) {
          transaction.update(user2Snapshot.reference, {
            'chats': FieldValue.arrayUnion([chatID]),
          });
        }
        Chat chatModel;
        if (chatSnapshot.exists) {
          chatModel =
              Chat.fromJson(chatSnapshot.data() as Map<String, dynamic>);
          chatModel.messages!.add(message);
          chatModel.lastMessage = message;
          chatModel.updatedAt = Timestamp.now();
          transaction.update(docRef, chatModel.toJson());
        } else {
          chatModel = Chat(
            id: chatID,
            participantsIds: [uid1, uid2],
            messages: [message],
            lastMessage: message,
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
            isGroupChat: false,
            unreadCount: 0,
          );
          transaction.set(docRef, chatModel.toJson());
        }
      });
    } catch (e) {
      print('Transaction failed: $e');
      throw e; // Rethrow the error for handling in the calling function
    }
  }

  // Retrieve chat data in form of stream
  Stream getChatData(String uid1, String uid2) {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatID);
    return docRef.snapshots() as Stream<DocumentSnapshot<Chat>>;
  }

  // FRIEND REQUEST METHODS

  // Accept friend request
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

  // Cancel friend request
  Future<void> cancelFriendRequest(
      String senderUid, String receiverUid, Function(bool) callback) async {
    await _firebaseFirestore.collection('users').doc(receiverUid).update({
      'friendReqList': FieldValue.arrayRemove([senderUid])
    });
    callback(false);
  }

  // Get all friends (list)
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
      _alertService.showToast(text: "User profile doesn't exists.");
    }
    return friends;
  }

  // Get mutual friends (list)
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
          commonFriends.add(UserProfile.fromJson(
              mutualFriendDoc?.data() as Map<String, dynamic>));
        }
      }
    } else {
      _alertService.showToast(text: "User profile doesn't exists.");
    }
    return commonFriends;
  }

  // Reject friend request
  Future<void> rejectFriendRequest(String receiverUid, String senderUid) async {
    await _firebaseFirestore.collection('users').doc(receiverUid).update({
      'friendReqList': FieldValue.arrayRemove([senderUid])
    });
  }

  // Remove friend
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

  // Send friend request
  Future<void> sendFriendRequest(
      String senderUid, String receiverUid, Function(bool) callback) async {
    await _firebaseFirestore.collection('users').doc(receiverUid).update({
      'friendReqList': FieldValue.arrayUnion([senderUid])
    });
    callback(true);
  }

  // MODULE METHODS

  // Add module to user's schedule
  Future<void> addModuleToUserSchedule(String userId, String moduleCode) async {
    DocumentReference userDoc =
        _firebaseFirestore.collection('users').doc(userId);
    await userDoc.update({
      'currentModule': FieldValue.arrayUnion([moduleCode])
    });
  }

  // Check if the module is in the user's completed modules
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

  // Check if the module is in the user's current modules
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

  // Remove modules from the user's schedule
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
