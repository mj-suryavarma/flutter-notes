import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notes/firebase_options.dart';
import 'package:my_notes/screen/login.dart';
import 'package:my_notes/screen/register.dart';
import 'package:my_notes/screen/verify.dart';

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
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
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
                     print("email is verified");
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
            PopupMenuButton<MenuAction>(onSelected: (value) => {},
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
