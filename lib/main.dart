import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_notes/constant/routes.dart';
import 'package:my_notes/helper/loading/loading_screen.dart';
import 'package:my_notes/screen/login.dart';
import 'package:my_notes/screen/note/create_update_note_view.dart';
import 'package:my_notes/screen/note/notes_view.dart';
import 'package:my_notes/screen/register.dart';
import 'package:my_notes/screen/verify.dart';
import 'package:my_notes/service/auth/firebase_auth_provider.dart';
import 'package:my_notes/service/bloc/auth_bloc.dart';
import 'package:my_notes/service/bloc/auth_event.dart';
import 'package:my_notes/service/bloc/auth_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'MJ Notes App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        //without bloc
        // loginRoute: (context) => const LoginView(),
        // registerRoute : (context) => const RegisterView(),
        // notesRoute : (context) => const NotesView(),
        // verifyEmailRoute : (context) => const EmailVerifyView(),
        createOrUpdateNoteRoute : (context) => const CreateUpdateNoteView(),
      },
    );
  }

}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // with bloc pattern
  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if(state.isLoading) {
            LoadingScreen().show(
                context: context,
                text: state.loadingText ?? 'Please wait a moment!',
            );
          } else {
            LoadingScreen().hide();
          }
        },
        builder: (context, state) {
          if(state is AuthStateLoggedIn) {
            return const NotesView();
          } else if(state is AuthStateNeedVerification) {
            return const EmailVerifyView();
          } else if(state is AuthStateLoggedOut) {
            return const LoginView();
          } else if(state is AuthStateRegistering) {
            return const RegisterView();
          } else {
            return const Scaffold(
              body: CircularProgressIndicator(),
            );
          }
        }
    );
  }


  // without bloc
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body:  FutureBuilder(
  //         future: AuthService.firebase().initialize(),
  //         builder: (context, snapshot) {
  //           switch(snapshot.connectionState) {
  //        case ConnectionState.done:
  //             final user = AuthService.firebase().currentUser;
  //             if(user != null) {
  //                 if(user.isEmailVerified) {
  //                    devtool.log("Email is Verified");
  //                    return NotesView();
  //                 } else {
  //                     return EmailVerifyView();
  //                 }
  //             }
  //              else  return LoginView();
  //
  //           default: return Text("Loading...");
  //           }
  //         }
  //
  //     ),
  //   );
  // }
}
