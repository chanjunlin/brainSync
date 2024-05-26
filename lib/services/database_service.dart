import 'package:brainsync/model/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference<UserProfile>? _usersCollection;

  DatabaseService() {
    setUpCollectionReferences();
  }

  void setUpCollectionReferences() {
    _usersCollection = _firebaseFirestore
        .collection('users')
        .withConverter<UserProfile>(
      fromFirestore: (snapshots, _) => UserProfile.fromJson(snapshots.data()!),
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
}
