import 'package:firebase_core/firebase_core.dart';
import 'package:my_notes/service/auth/auth_provider.dart';
import 'package:my_notes/service/auth/auth_service.dart';
import 'package:my_notes/service/auth/auth_user.dart';
import 'package:my_notes/service/auth/firebase_auth_provider.dart';

import '../../firebase_options.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> login({required String email, required String password}) => provider.login(email: email, password: password);

  @override
  Future<AuthUser> createUser({required String email, required String password}) =>  provider.createUser(email: email, password: password);


  @override
  AuthProvider? get currentUser => throw UnimplementedError();

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();
}