import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  StorageService() {}

  final FirebaseStorage _fireBaseStorage = FirebaseStorage.instance;

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
}
