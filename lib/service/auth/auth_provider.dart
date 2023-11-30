import 'package:my_notes/service/auth/auth_provider.dart';
import 'auth_user.dart';

abstract class AuthProvider {
   Future<void> initialize();
   AuthProvider? get currentUser;
   Future<AuthUser> login({
      required String email,
      required String password,
    });

   Future<AuthUser> createUser({
      required String email,
      required String password,
});
   Future<void> logOut();
   Future<void> sendEmailVerification();
}