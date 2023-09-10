import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notes/constant/routes.dart';
import 'package:my_notes/firebase_options.dart';
import 'package:my_notes/screen/login.dart';
import 'package:my_notes/screen/register.dart';
import 'package:my_notes/screen/verify.dart';
import 'dart:developer' as devtool show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Flutter Demo',
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
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch(snapshot.connectionState) {
         case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if(user != null) {
                  if(user.emailVerified) {
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

enum MenuAction {
  Logout
}

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome!, Main Ui"),
        backgroundColor: Colors.lightBlue,
        actions: [
            PopupMenuButton<MenuAction>(onSelected: (value) async {
              switch(value) {
                case MenuAction.Logout:
                  final shouldLogout = await showLogOutDialog(context);
                  devtool.log(shouldLogout.toString());
                  if(shouldLogout) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.Logout,
                child: Text("Log out"),
                )
              ];
          },)
        ],
      ),
    );
  }
}


Future<bool> showLogOutDialog(BuildContext context) {
 return showDialog<bool>(context: context, builder: (context) {
      return AlertDialog(
        title: const Text("Sign out"),
        content: const Text("Are you sure want to sign out"),
        actions: [
          TextButton(onPressed: () {
            Navigator.of(context).pop(false);
          }, child: const Text("Cancel")),

          TextButton(onPressed: () {
            Navigator.of(context).pop(true);
          }, child: const Text("Log out"))
        ]
      );
  }).then((value) =>  value ?? false);
}