import 'dart:async';

import 'package:brainsync/model/group_chat.dart';
import 'package:brainsync/model/post.dart';
import 'package:brainsync/model/user_profile.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../const.dart';
import '../model/chat.dart';
import '../model/comment.dart';
import '../model/message.dart';
import 'auth_service.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;

  CollectionReference<UserProfile>? _usersCollection;
  CollectionReference? _chatCollection, _groupChatCollection, _postCollection;

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
    _groupChatCollection = _firebaseFirestore
        .collection('groupChats')
        .withConverter<GroupChat>(
            fromFirestore: (snapshots, _) =>
                GroupChat.fromJson(snapshots.data()!),
            toFirestore: (groupChat, _) => groupChat.toJson());
    _postCollection = _firebaseFirestore
        .collection('posts')
        .withConverter<Post>(
            fromFirestore: (snapshots, _) => Post.fromJson(snapshots.data()!),
            toFirestore: (post, _) => post.toJson());
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

  // Creating a new group
  Future<void> createNewGroup(
      String groupID, String groupName, List<UserProfile?> members) async {
    final userId = _authService.currentUser!.uid;
    final DocumentSnapshot? userRef = await fetchCurrentUser();
    final groupDocRef = _groupChatCollection?.doc(groupID);

    var userProfile = userRef?.data() as Map<String, dynamic>;
    var participantsID = members.map((member) => member?.uid ?? '').toList();

    participantsID.add(userId);

    final groupChat = GroupChat(
      admins: [userId],
      createdBy: userId,
      createdAt: Timestamp.fromDate(DateTime.now()),
      groupID: groupID,
      groupDescription: "No description",
      groupName: groupName,
      groupPicture: PLACEHOLDER_PFP,
      participantsID: participantsID,
      messages: [],
    );

    await groupDocRef?.set(groupChat);

    final userDocs = participantsID.map((uid) {
      return _usersCollection?.doc(uid);
    }).toList();

    for (var docRef in userDocs) {
      if (docRef != null) {
        final DocumentSnapshot userSnapshot = await docRef.get();
        if (userSnapshot.exists) {
          List<dynamic> userGroupChat = userSnapshot.get("groupChats") ?? [];
          if (!userGroupChat.contains(groupID)) {
            userGroupChat.add(groupID);
            await docRef.update({'groupChats': userGroupChat});
          }
        }
      }
    }
  }

  // Retrieve chat details in DocumentSnapshot
  Future<DocumentSnapshot<Object?>> getChatDetails(String chatId) async {
    return _firebaseFirestore.collection('chats').doc(chatId).get();
  }

  // Retrieve group chat details in DocumentSnapshot
  Future<DocumentSnapshot?> getGroupChatDetails(String groupID) async {
    try {
      return _firebaseFirestore.collection('groupChats').doc(groupID).get();
    } catch (e) {
      _alertService.showToast(text: "Error fetching group chat details: $e");
      return null;
    }
  }

  // Retrieve all chats from user
  Stream<QuerySnapshot> getAllUserChatsStream() {
    return _firebaseFirestore
        .collection('chats')
        .where('participantsIds', arrayContains: _authService.currentUser!.uid)
        .snapshots();
  }

  // Retrieve all group chats from user
  Stream<QuerySnapshot> getAllUserGroupChatsStream() {
    return _firebaseFirestore
        .collection('groupChats')
        .where('participantsID', arrayContains: _authService.currentUser!.uid)
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
      rethrow;
    }
  }

  // Sending a group chat message
  Future<void> sendGroupChatMessage(String groupID, Message message) async {
    final docRef =
        FirebaseFirestore.instance.collection('groupChats').doc(groupID);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot chatSnapshot = await transaction.get(docRef);
        if (!chatSnapshot.exists) {
          throw Exception('Group chat does not exist');
        }
        Map<String, dynamic> chatData =
            chatSnapshot.data() as Map<String, dynamic>;
        GroupChat chatModel = GroupChat.fromJson(chatData);
        chatModel.messages!.add(message);
        chatModel.lastMessage = message;
        chatModel.updatedAt = Timestamp.now();
        transaction.update(docRef, chatModel.toJson());
      });
    } catch (e) {
      print('Transaction failed: $e');
      rethrow;
    }
  }

  // Retrieve chat data in form of stream
  Stream getChatData(String uid1, String uid2) {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatID);
    return docRef.snapshots() as Stream<DocumentSnapshot<Chat>>;
  }

  // Retrieve group chat data in from of stream
  Stream getGroupChatData(String groupID) {
    final docRef = _groupChatCollection!.doc(groupID);
    return docRef.snapshots() as Stream<DocumentSnapshot<GroupChat>>;
  }

  // Add friends to group
  Future<void> addFriend(String groupID, List<UserProfile?> members) async {
    var participantsID = members.map((member) => member?.uid ?? '').toList();
    final groupChatRef = _groupChatCollection!.doc(groupID);
    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentSnapshot groupChatSnapshot = await transaction.get(groupChatRef);
      for (var participant in participantsID) {
        final userRef = _usersCollection!.doc(participant);
        transaction.update(userRef, {
          'groupChats': FieldValue.arrayUnion([groupID]),
        });
      }
      transaction.update(groupChatRef, {
        'participantsID': FieldValue.arrayUnion(participantsID),
      });
    });
  }

  // Leaving the group chat
  Future<void> leaveGroupChat(String groupID, String uid) async {
    final groupChatRef = _groupChatCollection!.doc(groupID);
    final userRef = _usersCollection!.doc(uid);

    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentSnapshot groupChatSnapshot = await transaction.get(groupChatRef);
      List<dynamic> admins = groupChatSnapshot.get('admins');

      if (admins.contains(uid)) {
        transaction.update(groupChatRef, {
          'admins': FieldValue.arrayRemove([uid]),
        });
      }
      transaction.update(groupChatRef, {
        'participantsID': FieldValue.arrayRemove([uid]),
      });
      transaction.update(userRef, {
        'groupChats': FieldValue.arrayRemove([groupID])
      });
    });
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
    print(commonFriends);
    return commonFriends;
  }

  // Reject friend request
  Future<void> rejectFriendRequest(String senderUid, String receiverUid) async {
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
  Future<void> addModuleToUserSchedule(
      String userId, String addedModule) async {
    DocumentReference userDoc =
        _firebaseFirestore.collection('users').doc(userId);
    await userDoc.update({
      'currentModules': FieldValue.arrayUnion([addedModule]),
    });
  }

  // Check if the module is in the user's completed modules
  Future<bool> isInCompletedModule(String userId, String moduleCode) async {
    try {
      DocumentSnapshot userDoc =
          await _firebaseFirestore.collection('users').doc(userId).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<String> computedModules =
          List<String>.from(userData['completedModules'] ?? []);
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
          List<String>.from(userData['currentModules'] ?? []);
      return currentModules.contains(moduleCode);
    } catch (error) {
      print("Error checking current module: $error");
      return false;
    }
  }

  // Remove modules from the user's schedule
  Future<void> removeModule(
      String userId, String moduleCode, String moduleCredit) async {
    try {
      DocumentSnapshot userDoc =
          await _firebaseFirestore.collection('users').doc(userId).get();
      String completeCode = '$moduleCode/$moduleCredit';
      List<dynamic>? currentModules = userDoc["currentModules"];
      if (currentModules != null && currentModules.contains(completeCode)) {
        currentModules.remove(completeCode);
        await userDoc.reference.update({
          'currentModules': currentModules,
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // Converting module from current to completed
  Future<void> moduleIsCompleted(
      String userId, String moduleCode, String moduleCredit) async {
    try {
      DocumentSnapshot userDoc =
          await _firebaseFirestore.collection('users').doc(userId).get();
      String completeCode = '$moduleCode/$moduleCredit';
      List<dynamic>? currentModules = userDoc["currentModules"];
      List<dynamic>? completedModules = userDoc["completedModules"];
      completedModules?.add(completeCode as dynamic);
      if (currentModules != null && currentModules.contains(completeCode)) {
        currentModules.remove(completeCode);
        await userDoc.reference.update({
          'currentModules': currentModules,
          'completedModules': completedModules,
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // POST METHODS

  // Creating a post
  Future<void> createNewPost({required Post post}) async {
    try {
      DocumentReference postRef = _postCollection!.doc();
      DocumentReference newPost = _postCollection!.doc(postRef.id);
      final userId = _authService.currentUser!.uid;
      final userRef = _usersCollection!.doc(userId);
      String postRefId = postRef.id;
      newPost.set(post);
      await newPost.update(
        {
          'id': postRefId,
          'likes': [],
          'commentCount': 0,
        },
      );
      await userRef.update({
        'myPosts': FieldValue.arrayUnion([postRef.id])
      });
    } catch (e) {}
  }

  // Fetching all posts
  Future<QuerySnapshot> fetchPosts() async {
    try {
      QuerySnapshot querySnapshot =
          await _postCollection!.orderBy('timestamp', descending: true).get();
      return querySnapshot;
    } catch (e) {
      rethrow;
    }
  }

  // Fetching DocumentSnapshot of specific post
  Future<DocumentSnapshot> fetchPost(String postId) async {
    return await _postCollection!.doc(postId).get();
  }

  // Fetching user's bookmarked posts
  Future<List<DocumentSnapshot>> fetchBookmarkedPosts() async {
    try {
      DocumentSnapshot? userDocs = await fetchCurrentUser();
      if (userDocs != null && userDocs.exists) {
        Map<String, dynamic> userData = userDocs.data() as Map<String, dynamic>;
        List<dynamic> bookmarkedPostIds = userData['bookmarks'] ?? [];
        List<DocumentSnapshot> bookmarkedPosts = [];
        for (var postId in bookmarkedPostIds) {
          DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .get();
          bookmarkedPosts.add(postSnapshot);
        }
        return bookmarkedPosts;
      } else {
        throw "error";
      }
    } catch (e) {
      _alertService.showToast(text: "User profile doesn't exists.");
      rethrow;
    }
  }

  // Fetching user's posts
  Future<QuerySnapshot> fetchUserPosts(List<String> postId) async {
    try {
      QuerySnapshot postSnapshot = await _firebaseFirestore
          .collection('posts')
          .where(FieldPath.documentId, whereIn: postId)
          .orderBy('timestamp', descending: true)
          .get();
      return postSnapshot;
    } catch (e) {
      print('Error fetching posts: $e');
      rethrow;
    }
  }

  // Bookmarking a post
  Future<void> addBookmark(String postId) async {
    try {
      final userId = _authService.currentUser!.uid;
      final userRef = _usersCollection!.doc(userId);
      await userRef.update({
        'bookmarks': FieldValue.arrayUnion([postId])
      });
    } catch (e) {
      print(e);
    }
  }

  // Removing post from bookmark
  Future<void> removeBookmark(String postId) async {
    try {
      final userId = _authService.currentUser!.uid;
      final userRef = _usersCollection!.doc(userId);
      await userRef.update({
        'bookmarks': FieldValue.arrayRemove([postId])
      });
    } catch (e) {
      print(e);
    }
  }

  // Liking a post
  Future<void> likePost(String postID) async {
    try {
      final userID = _authService.currentUser!.uid;
      await _postCollection!.doc(postID).update(
        {
          'likes': FieldValue.arrayUnion([userID]),
        },
      );
      await _usersCollection!.doc(userID).update({
        'myLikedPosts': FieldValue.arrayUnion([postID]),
      });
    } catch (e) {
      print(e);
    }
  }

  // Unliking a post
  Future<void> dislikePost(String postID) async {
    try {
      final userID = _authService.currentUser!.uid;
      await _postCollection!.doc(postID).update(
        {
          'likes': FieldValue.arrayRemove([userID])
        },
      );
      await _usersCollection!.doc(userID).update({
        'myLikedPosts': FieldValue.arrayRemove([postID]),
      });
    } catch (e) {
      print(e);
    }
  }

  // Adding a comment
  Future<void> addNewcomment(String postID, Comment comment) async {
    try {
      final postRef = _postCollection!.doc(postID);
      final userID = _authService.currentUser!.uid;

      await _firebaseFirestore.runTransaction((transaction) async {
        DocumentSnapshot postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) {
          print("Post does not exist!");
        }
        transaction.update(postRef, {
          "commentCount": FieldValue.increment(1),
        });
        await postRef.collection('comments').add(comment.toJson());
      });
    } catch (e) {
      print(e);
    }
  }

  // Liking a comment
  Future<void> likeComment(
      String postID, String commentID, String userID) async {
    try {
      final postRef = _postCollection!.doc(postID);
      final commentRef = postRef.collection("comments").doc(commentID);
      final String combinedRef = "$postID/$commentID";
      await commentRef.update({
        'likes': FieldValue.arrayUnion([userID])
      });
      await _usersCollection!.doc(userID).update({
        'myLikedComments': FieldValue.arrayUnion([combinedRef]),
      });
    } catch (e) {
      print("Error liking comment");
    }
  }

  // Disliking a comment
  Future<void> dislikeComment(
      String postID, String commentID, String userId) async {
    try {
      final postRef = _postCollection!.doc(postID);
      final commentRef = postRef.collection("comments").doc(commentID);
      await commentRef.update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      print("Error liking comment");
    }
  }
}
