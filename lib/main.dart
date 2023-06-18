import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notes/firebase_options.dart';
import 'package:my_notes/screen/login.dart';
import 'package:my_notes/screen/register.dart';

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
    );
  }

}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome!'),
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 25
        ),
        backgroundColor: Colors.blue ,
      ),
      body:  FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch(snapshot.connectionState) {
              case ConnectionState.done:
                final user = FirebaseAuth.instance.currentUser;
                if(user?.emailVerified ?? false) {
                  print("Email is Verified");
                } else {
                  print("you need to verify your email first!");
                }
                return  Text("Done");
              default: return Text("Loading...");
            }


          }

      ),
    );
  }
}