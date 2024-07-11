import 'dart:io';

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
    required File profileFile,
    required String uid,
  }) async {
    Reference profileFileRef = _fireBaseStorage
        .ref('users/pfp')
        .child('$uid${p.extension(profileFile.path)}');
    UploadTask profileTask = profileFileRef.putFile(profileFile);
    return profileTask.then((p) {
      if (p.state == TaskState.success) {
        return profileFileRef.getDownloadURL();
      }
      return null;
    });
  }

  Future<String?> uploadUserCover({
    required File coverFile,
    required String uid,
  }) async {
    Reference coverFileRef = _fireBaseStorage
        .ref('users/profileCover')
        .child('$uid${p.extension(coverFile.path)}');
    UploadTask coverTask = coverFileRef.putFile(coverFile);
    return coverTask.then((p) {
      if (p.state == TaskState.success) {
        return coverFileRef.getDownloadURL();
      }
      return null;
    });
  }

  Future<String> saveData({
    File? coverFile,
    File? profileFile,
    required String uid,
    required String firstName,
    required String lastName,
    required String year,
    required String bio,
  }) async {
    String userId = _authService.currentUser!.uid;
    String? downloadProfileURL;
    String? downloadCoverURL;
    if (profileFile != null) {
      downloadProfileURL = await uploadUserProfile(
        profileFile: profileFile,
        uid: uid,
      );
    }
    if (coverFile != null) {
      downloadCoverURL = await uploadUserCover(
        coverFile: coverFile,
        uid: uid,
      );
    }
    Map<String, dynamic> updateData = {
      'firstName': firstName,
      'lastName': lastName,
      'year': year,
      'bio': bio,
    };
    if (downloadProfileURL != null) {
      updateData['pfpURL'] = downloadProfileURL;
    }
    if (downloadCoverURL != null) {
      updateData['profileCoverURL'] = downloadCoverURL;
    }
    await _firestore.collection('users').doc(userId).update(updateData);
    _alertService.showToast(
      text: "Profile updated successfully!",
      icon: Icons.check,
    );
    return "passed";
  }

  Future<String?> uploadImageToChat(
      {required File file, required String chatID}) async {
    Reference fileRef = _fireBaseStorage
        .ref('chats/$chatID')
        .child('${DateTime.now().toIso8601String()}${p.extension(file.path)}');
    UploadTask task = fileRef.putFile(file);
    return task.then((p) {
      if (p.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
      return null;
    });
  }
}
