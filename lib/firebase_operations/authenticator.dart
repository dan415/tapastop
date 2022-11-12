import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthenticator {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> createUser(email, password) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (cred.user != null && !cred.user!.emailVerified) {
      await cred.user!.sendEmailVerification();
    }
    return cred.user!.uid;
  }

  // Get current uid 
    String? getCurrentUID() {
        return _auth.currentUser?.uid;
    }

  login(email, password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return false;
      
      } else if (e.code == 'wrong-password') {
        return false;
      }
    }
  }
}
