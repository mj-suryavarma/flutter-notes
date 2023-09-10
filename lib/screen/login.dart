

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_notes/constant/routes.dart';
import 'package:my_notes/firebase_options.dart';
import 'dart:developer' as devtools show log;

import 'package:my_notes/utilities/dialog-service.dart';

class LoginView extends StatefulWidget {

  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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

                 return   Container(
                     margin: EdgeInsets.all((30)),
                     child:  Center(
                         child: Column(
                           children: [
                             TextField(
                               autofocus: true,
                               controller: _email,
                               decoration: InputDecoration(
                                   hintText: 'Enter your email here'
                               ),
                             ),
                             TextField(
                               controller: _password,
                               obscureText: true,
                               enableSuggestions: false,
                               autocorrect: false,
                               decoration: InputDecoration(
                                   hintText: 'Enter your password here'
                               ),
                             ),
                             TextButton(
                               onPressed: () async {
                                 await Firebase.initializeApp(
                                   options: DefaultFirebaseOptions.currentPlatform,
                                 );
                                 final email = _email.text;
                                 final password = _password.text;
                                 try {
                                   final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                       email: email, password: password
                                   );
                                   devtools.log(userCredential.toString());
                                   Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
                                 } on FirebaseAuthException catch(e) {

                                   if(e.message!.contains("user-not-found")) {
                                     devtools.log("User not found");
                                    await showErrorDialog(context, "User Not Found");
                                   } else if(e.message!.contains("invalid-email")) {
                                     devtools.log("Invalid Email");
                                     await showErrorDialog(context, "Invalid Email");
                                   }
                                   else if(e.message!.contains("wrong-password")) {
                                     devtools.log("Wrong Credentials");
                                     await showErrorDialog(context, "Wrong Credentials");
                                   }
                                   else {
                                     devtools.log(e.toString());
                                     await showErrorDialog(context, "Error ${e.code.toString()}");
                                   }
                                 } catch(e) {
                                   await showErrorDialog(context, e.toString());
                                 }
                               },
                               child: const Text(
                                 "Login",
                                 style: TextStyle(
                                     color: Colors.blue,
                                     backgroundColor: Colors.white
                                 ),
                               ),
                             ),
                             TextButton(
                                 onPressed: () {
                                   Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
                                 },
                                 child: const Text("Not register yet ? register here!")
                             )
                           ],
                         )
                     )

                 );

                 return const Text("Done");
              // default: return Text("Loading...");
                default: return CircularProgressIndicator();
             }


           }

       ),
    );
  }

}
