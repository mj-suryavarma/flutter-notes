import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notes/constant/routes.dart';
import 'package:my_notes/firebase_options.dart';
import 'package:my_notes/screen/login.dart';
import 'package:my_notes/screen/notes_view.dart';
import 'package:my_notes/screen/register.dart';
import 'package:my_notes/screen/verify.dart';
import 'dart:developer' as devtool show log;

import 'package:my_notes/service/auth/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'MJ Notes App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute : (context) => const RegisterView(),
        notesRoute : (context) => const NotesView(),
        verifyEmailRoute : (context) => const EmailVerifyView(),
      },
    );
  }

}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  FutureBuilder(
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            switch(snapshot.connectionState) {
         case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if(user != null) {
                  if(user.isEmailVerified) {
                     devtool.log("Email is Verified");
                     return NotesView();
                  } else {
                      return EmailVerifyView();
                  }
              }
               else  return LoginView();

            default: return Text("Loading...");
            }
          }

      ),
    );
  }
}

