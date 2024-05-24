import 'package:brainsync/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService{

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;

  User? get user {
    return _user;
  }

  User? get currentUser {
    return _firebaseAuth.currentUser;
  }

  AuthService() {}

  Future<bool> login(String email, String password) async {
    try{
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      if (credential.user != null) {
        _user = credential.user;
        print(_user);
        return true;
      }
    } catch(e) {
      print(e);
    }
    return false;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  void authChangeStreamListener(User? user) {
    if (user != null) {
      _user = user;
    } else {
      _user = null;
    }
  }
}