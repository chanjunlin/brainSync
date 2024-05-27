import 'dart:async';

import 'package:brainsync/auth.dart';
import 'package:brainsync/model/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'auth_service.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;

  CollectionReference<UserProfile>? _usersCollection;

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

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _usersCollection
        ?.where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }
}
