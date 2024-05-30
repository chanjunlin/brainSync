import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'alert_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GetIt _getIt = GetIt.instance;

  late AlertService _alertService;

  User? _user;

  User? get user {
    return _user;
  }

  User? get currentUser {
    return _firebaseAuth.currentUser;
  }

  AuthService() {
    // _alertService = _getIt.get<AlertService>();
  }

  Future<bool> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        _user = credential.user;
        print(_user);
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {}
    return false;
  }

  void authChangeStreamListener(User? user) {
    if (user != null) {
      _user = user;
    } else {
      _user = null;
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
      return e.toString();
    }
    return "false";
  }
}
