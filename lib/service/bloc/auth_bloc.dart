import 'package:bloc/bloc.dart';
import 'package:my_notes/service/auth/auth_provider.dart';
import 'package:my_notes/service/bloc/auth_event.dart';
import 'package:my_notes/service/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
    AuthBloc(AuthProvider provider): super(const AuthStateUninitialized(isLoading: true)) {
     // send email verification
      on<AuthEventSendEmailVerification>((event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      });

      on<AuthEventRegister>((event, emit) async {
        final email = event.email;
        final password = event.password;
        try {
          await provider.createUser(email: email, password: password);
          await provider.sendEmailVerification();
          emit(const AuthStateNeedVerification(isLoading: false));
        } on Exception catch(e) {
            emit(AuthStateRegistering(
                exception: e,
                isLoading: false,
            ));
        }
      });

      on<AuthEventShouldRegister>((event, emit) async {
       try{
        } on Exception catch(e) {
          emit(AuthStateRegistering(
              exception: e,
              isLoading: false,
          ));
        }
      });

     // initialize
     on<AuthEventInitialize>((event, emit) async {
       await provider.initialize();
       final user = provider.currentUser;
       if(user == null) {
         emit(const AuthStateLoggedOut(
           exception: null,
           isLoading: false,
           loadingText: 'Please Wait while i log you in',
         ));
       } else if(!user.isEmailVerified) {
         emit(const AuthStateNeedVerification(isLoading: false));
       } else {
         emit(AuthStateLoggedIn(
             user: user,
             isLoading: false
         ));
       }
     });

     on<AuthEventLogin>((event, emit) async {
       await Future.delayed(const Duration(seconds: 3));
       try {
         final email = event.email;
         final password = event.password;
         final user = await provider.login(
              email: email,
              password: password
          );
         if(!user.isEmailVerified) {
           emit(const AuthStateLoggedOut(exception: null, isLoading: false));
           emit(const AuthStateNeedVerification(isLoading: false));
         } else {
           emit(const AuthStateLoggedOut(exception: null, isLoading: false));
         }
          emit(AuthStateLoggedIn(
              user: user,
              isLoading: false
          ));
        } on Exception catch(e) {
          emit(AuthStateLoggedOut(
            isLoading: false,
            exception: e
          ));
        }

     });

     on<AuthEventLogout>((event, emit) async {
         try {
           await provider.logOut();
           emit(
             const AuthStateLoggedOut(exception: null, isLoading: false),
           );
         } on Exception catch(e) {
           emit(
              AuthStateLoggedOut(exception: e, isLoading: false),
           );
         }
     });
   }
}