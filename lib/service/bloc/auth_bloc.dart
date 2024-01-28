import 'package:bloc/bloc.dart';
import 'package:my_notes/service/auth/auth_provider.dart';
import 'package:my_notes/service/bloc/auth_event.dart';
import 'package:my_notes/service/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {

    //register screen
    on<AuthEventShouldRegister>((event, emit) async {
       emit(const AuthStateRegistering(
           exception: null,
           isLoading: false
       ));
    });

    // forgot password
    on<AuthEventForgetPassword>((event, emit) async {
      emit(const AuthStateForgetPassword(
        exception: null,
        hasSendEmail: false,
        isLoading: false,
      ));
      final email = event.email;
      if (email == null) {
        return; //user just want to got forgot password screen
      }

      //  user want to actually send a forgot-password email
      emit(const AuthStateForgetPassword(
        exception: null,
        hasSendEmail: false,
        isLoading: true,
      ));

      bool didSendEmail;
      Exception? exception;

      try {
        await provider.sendPasswordReset(toEmail: email);
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }

      emit(AuthStateForgetPassword(
        exception: exception,
        hasSendEmail: didSendEmail,
        isLoading: false,
      ));

    });

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
      } on Exception catch (e) {
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
      if (user == null) {
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });

    on<AuthEventLogin>((event, emit) async {
      emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait a moment'));
      print(' heyyyyy bloc consumer loading state ${state.isLoading}');
      await Future.delayed(const Duration(seconds: 3));
      try {
        final email = event.email;
        final password = event.password;
        final user = await provider.login(email: email, password: password);
        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(const AuthStateNeedVerification(isLoading: false));
        } else {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        }
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(isLoading: false, exception: e));
      }
    });

    on<AuthEventLogout>((event, emit) async {
      try {
        await provider.logOut();
        emit(
          const AuthStateLoggedOut(exception: null, isLoading: false),
        );
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(exception: e, isLoading: false),
        );
      }
    });
  }
}
