import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:my_notes/service/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment'
});
}

class AuthStateUninitialized extends AuthState {
   const AuthStateUninitialized({required super.isLoading});
}

class AuthStateRegistering extends AuthState {
   final Exception exception;
   const AuthStateRegistering({required this.exception, required super.isLoading});
}

class AuthStateLoading extends AuthState {
   const AuthStateLoading({required super.isLoading});
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({required this.user, required super.isLoading});
}

class AuthStateNeedVerification extends AuthState {
   const AuthStateNeedVerification({required super.isLoading});
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
   final Exception? exception;
   final bool isLoading;
   const AuthStateLoggedOut({
     required this.exception,
     required this.isLoading,
     String? loadingText
   }) : super(
       isLoading: isLoading,
       loadingText: loadingText
     );

  @override
  List<Object?> get props => [exception, isLoading];
}

