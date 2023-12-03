import 'package:my_notes/service/auth/auth-execption.dart';
import 'package:my_notes/service/auth/auth_provider.dart';
import 'package:my_notes/service/auth/auth_user.dart';
import 'package:test/test.dart';

 void main() {
        group("Mock Authentication", () {
          final provider = MockAuthProvider();
          
          test("should not be initialized to begin with", () {
            expect(provider.isInitialized, false);
          });

          test("should be able to initialized", () async {
           await provider.initialize();
           expect(provider.isInitialized, true);
          });

          test("User should be null after initialization", () {
           expect(provider.currentUser, null);
          });

          test("Should be able to initialized in less than 2 seconds", () async {
           await provider.initialize();
           expect(provider.isInitialized, true);
          }, timeout: const Timeout(Duration(seconds: 2)));

          test("Create user should delegate to login function", () async {
            await provider.initialize();
            final badEmailUser = await provider.createUser(email: "mj@gmail.com", password: "Test1234");
            expect(badEmailUser, throwsA(const TypeMatcher<NotInitializedException>()));

            final badPasswordUser = await provider.createUser(email: "mj@gmail.com", password: "Test1234");
            expect(badPasswordUser, throwsA(const TypeMatcher<WrongPasswordException>()));

            final user = await provider.createUser(email: "mj@gmail.com", password: "Test1234");
            expect(provider.currentUser, user);
            expect(user.isEmailVerified, false);
          });

          test("Logged in user should be able to get verified", () async {
            await provider.sendEmailVerification();
            final user = provider.currentUser;
            expect(user, isNotNull);
            expect(user!.isEmailVerified, true);
          });

          test("User should be able to logout and login again", () async {
           await provider.logOut();
           await provider.login(email: "abc@gmail.com", password: "1241");
           final user = provider.currentUser;
           expect(user, isNotNull);
          });


          test("Cannot logout if not initialized", () {
            expect(provider.logOut(), throwsA(const TypeMatcher<UserNotFoundException>()));
          });

        });
 }

 class NotInitializedException implements Exception {}

 class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
    if(!_isInitialized) throw NotInitializedException();
   await Future.delayed(const Duration(seconds: 1));
   return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<void> logOut() async {
   if(!isInitialized) throw NotInitializedException();
   if(_user == null) throw UserNotFoundException();
   await Future.delayed(const Duration(seconds: 1));
   _user = null;
  }

  @override
  Future<AuthUser> login({required String email, required String password}) {
   if(!isInitialized) throw NotInitializedException();
   if(email == "dj@gamil.com") throw UserNotFoundException();
   if(password == "dj1234") throw WrongPasswordException();
   const user = AuthUser(isEmailVerified: false);
   _user = user;
   return Future.value(user);
  }

  @override
  Future<void> sendEmailVerification() async {
   if(!isInitialized) throw NotInitializedException();
   if(_user == null) throw UserNotFoundException();
   const newUser = AuthUser(isEmailVerified: true);
   _user = newUser;
  }

 }