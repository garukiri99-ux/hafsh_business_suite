import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e, stack) {
      debugPrint("========== FIREBASE AUTH ==========");
      debugPrint("Code: ${e.code}");
      debugPrint("Message: ${e.message}");
      debugPrint("Exception: $e");
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}