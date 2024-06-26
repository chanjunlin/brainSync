import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookmarkProvider with ChangeNotifier {
  final String userId;
  BookmarkProvider(this.userId) {
    _loadBookmarks();
  }

  Map<String, bool> _bookmarks = {};

  Map<String, bool> get bookmarks => _bookmarks;

  Future<void> _loadBookmarks() async {
    if (userId == null) return;
    
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    try {
      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        List<String> bookmarks = List<String>.from(userSnapshot.data()?['bookmarks'] ?? []);
        _bookmarks = {for (var postId in bookmarks) postId: true};
        notifyListeners();
      }
    } catch (e) {
      // Handle errors as appropriate
      print('Error loading bookmarks: $e');
    }
  }

  Future<void> toggleBookmark(String postId) async {
    if (userId == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    try {
      if (_bookmarks[postId] == true) {
        await userRef.update({
          'bookmarks': FieldValue.arrayRemove([postId])
        });
        _bookmarks[postId] = false;
      } else {
        await userRef.update({
          'bookmarks': FieldValue.arrayUnion([postId])
        });
        _bookmarks[postId] = true;
      }
      notifyListeners();
    } catch (e) {
      // Handle errors as appropriate
      print('Error toggling bookmark: $e');
    }
  }
}