import 'package:firebase_core/firebase_core.dart';
import 'package:my_notes/service/auth/auth_user.dart';
import 'package:my_notes/service/auth/auth_provider.dart';
import 'package:my_notes/service/auth/auth-execption.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;

import '../../firebase_options.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> login({required String email, required String password}) async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        final user = currentUser;
        if(user != null) {
          return user;
        } else {
          throw UserNotLoggedInAuthException();
        }
      }  on FirebaseAuthException catch(e) {

      } catch (_) { }
  }

  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if(user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch(e) {

      if(e.message!.contains("weak-password")) {
        throw WeakPasswordAuthException();
      } else if(e.message!.contains("email-already-in-use")) {
        throw EmailAlreadyInUseAuthException();
      } else if(e.message!.contains("invalid-email")) {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    }
  }

  @override
  AuthProvider? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null) {
     return AuthProvider.fromFirebase(user);
    } else {
      return null;
     }
  }

  @override
  Future<void> logOut() async {
   final user = FirebaseAuth.instance.currentUser;
   if(user != null) {
     await FirebaseAuth.instance.signOut();
   } else {
     throw UserNotLoggedInAuthException();
   }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
}