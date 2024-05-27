import 'dart:io';
import 'dart:typed_data';

import 'package:brainsync/services/alert_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;

import 'auth_service.dart';

class StorageService {
  final GetIt _getIt = GetIt.instance;

  final FirebaseStorage _fireBaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AuthService _authService;
  late AlertService _alertService;

  StorageService() {
    _authService = _getIt.get<AuthService>();
    _alertService = _getIt.get<AlertService>();
  }

  Future<String?> uploadUserProfile({
    required File file,
    required String uid,
  }) async {
    Reference fileRef = _fireBaseStorage
        .ref('users/pfp')
        .child('$uid${p.extension(file.path)}');
    UploadTask task = fileRef.putFile(file);
    return task.then((p) {
      if (p.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
    });
  }

  Future<String> saveData({required File file, required String uid}) async {
    String userId = _authService.user!.uid;
    String? downloadURL = await uploadUserProfile(
      file: file,
      uid: uid,
    );
    print("before");
    await _firestore.collection('users').doc(userId).update({
      'pfpURL': downloadURL,
    });
    _alertService.showToast(
      text: "Profile picture updated successfully!",
      icon: Icons.check,
    );
    return "pased";
  }
}
