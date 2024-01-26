import 'package:flutter/foundation.dart' show immutable;
import 'package:my_notes/service/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateLoading extends AuthState {
   const AuthStateLoading();
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}

class AuthStateNeedVerification extends AuthState {
   const AuthStateNeedVerification();
}

class AuthStateLoggedOut extends AuthState {
   final Exception? exception;
   const AuthStateLoggedOut(this.exception);
}

class AuthStateLogoutFailure extends AuthState {
   final Exception exception;
   const AuthStateLogoutFailure(this.exception);
}