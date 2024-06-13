import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../const.dart';
import '../model/user_profile.dart';

class AuthService {
  String lastName = "", selectedYear = "";
  List<String?> friendReqList = [], friendList = [];
  

  User? _user;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference<UserProfile>? _usersCollection;

  AuthService() {
    setUpCollectionReferences();
  }

  void setUpCollectionReferences() {
    _usersCollection =
        _firebaseFirestore.collection('users').withConverter<UserProfile>(
              fromFirestore: (snapshots, _) =>
                  UserProfile.fromJson(snapshots.data()!),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );
  }

  User? get user => _user;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<bool> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        _user = credential.user;
        if (_user!.emailVerified) {
          return true;
        } else {
          await _firebaseAuth.signOut();
          throw Exception("Please verify your email before logging in.");
        }
      }
    } catch (e) {
      print(e);
      throw e;
    }
    return false;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      _user = userCredential.user;

      if (userCredential.user != null) {
        bool userExists = await checkIfUserExists(userCredential.user!.uid);
        if (!userExists) {
          await createUserProfile(
            userProfile: UserProfile(
              uid: userCredential.user!.uid,
              firstName: userCredential.user!.displayName,
              lastName: lastName,
              pfpURL: PLACEHOLDER_PFP,
              profileCoverURL: PLACEHOLDER_PROFILE_COVER,
              friendList: friendList,
              friendReqList: friendReqList,
              year: selectedYear,
              completedModules: [],
              currentModules: [],
            ),
          );
        } else {
          UserProfile userProfile =
              await getUserProfile(userCredential.user!.uid);
          await userCredential.user!.updateDisplayName(userProfile.firstName);
        }
      }
    } catch (e) {
      print("Error signing in with Google: $e");
    }
  }

  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<String> register(String name, String password, String email) async {
    try {
      UserCredential result = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (result.user != null) {
        _user = result.user;
        user?.updateDisplayName(name);
        return "true";
      }
    } catch (e) {
      print(e);
      return e.toString();
    }
    return "false";
  }

  Future<void> sendEmailVerification() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      print("Email verification sent");
    } catch (e) {
      print('Error sending verification email: $e');
    }
  }

  Future<UserProfile> getUserProfile(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userProfileSnapshot =
          await _firebaseFirestore.collection('users').doc(uid).get();
      if (userProfileSnapshot.exists) {
        return UserProfile.fromJson(userProfileSnapshot.data()!);
      } else {
        throw throw Exception("User profile not found");
      }
    } catch (e) {
      print('Error retrieving user profile: $e');
      throw e;
    }
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    try {
      await _usersCollection?.doc(userProfile.uid).set(userProfile);
      print("Profile created");
    } catch (e) {
      print('Error creating user profile: $e');
      throw e;
    }
  }

  Future<bool> checkIfUserExists(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userData =
          await _firebaseFirestore.collection('users').doc(uid).get();
      return userData.exists;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  void authChangeStreamListener(User? user) {
    if (user != null) {
      _user = user;
    } else {
      _user = null;
    }
  }
}
