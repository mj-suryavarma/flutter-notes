import 'package:bloc/bloc.dart';
import 'package:my_notes/service/auth/auth_provider.dart';
import 'package:my_notes/service/bloc/auth_event.dart';
import 'package:my_notes/service/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
    AuthBloc(AuthProvider provider): super(const AuthStateUninitialized()) {
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
          emit(const AuthStateNeedVerification());
        } on Exception catch(e) {
            emit(AuthStateRegistering(e));
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
         ));
       } else if(!user.isEmailVerified) {
         emit(const AuthStateNeedVerification());
       } else {
         emit(AuthStateLoggedIn(user));
       }
     });

     on<AuthEventLogin>((event, emit) async {
       emit(const AuthStateLoggedOut(exception: null, isLoading: true));
       try {
         final email = event.email;
         final password = event.password;
         final user = await provider.login(
              email: email,
              password: password
          );
         if(!user.isEmailVerified) {
           emit(const AuthStateLoggedOut(exception: null, isLoading: false));
           emit(const AuthStateNeedVerification());
         } else {
           emit(const AuthStateLoggedOut(exception: null, isLoading: false));
         }
          emit(AuthStateLoggedIn(user));
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