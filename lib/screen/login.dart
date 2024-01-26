

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_notes/constant/routes.dart';
import 'package:my_notes/firebase_options.dart';
import 'package:my_notes/service/auth/auth-execption.dart';
import 'package:my_notes/service/auth/auth_service.dart';
import 'package:my_notes/service/bloc/auth_bloc.dart';
import 'package:my_notes/service/bloc/auth_event.dart';
import 'package:my_notes/service/bloc/auth_state.dart';
import 'dart:developer' as devtools show log;
import 'package:my_notes/utilities/dialogs/error_dialog.dart';


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
                     margin: const EdgeInsets.all((30)),
                     child:  Center(
                         child: Column(
                           children: [
                             TextField(
                               autofocus: true,
                               controller: _email,
                               decoration: const InputDecoration(
                                   hintText: 'Enter your email here'
                               ),
                             ),
                             TextField(
                               controller: _password,
                               obscureText: true,
                               enableSuggestions: false,
                               autocorrect: false,
                               decoration: const InputDecoration(
                                   hintText: 'Enter your password here'
                               ),
                             ),
                             BlocListener(listener: (context, state) async {
                               if(state is AuthStateLoggedOut) {
                                 if(state is UserNotFoundException) {
                                    await showErrorDialog(context, "User Not Found ");
                                 } else if(state is WrongPasswordException) {
                                    await showErrorDialog(context, "Wrong Credentials");
                                 } else if(state is GenericAuthException) {
                                    await showErrorDialog(context, "Authentication Error Occurred");
                                 }
                               }
                             },
                             child:  TextButton(
                               onPressed: () async {
                                 await AuthService.firebase().initialize();
                                 final email = _email.text;
                                 final password = _password.text;
                                   //with bloc
                                   context.read<AuthBloc>().add(AuthEventLogin(
                                       email,
                                       password
                                   ),
                                   );

                                   // without bloc -- for leaning purpose
                                 // try {
                                   // final userCredential = await AuthService.firebase().login(email: email, password: password);
                                   // final user = AuthService.firebase().currentUser;
                                   // if(user?.isEmailVerified ?? false) {
                                   // // email is verified
                                   //  Navigator.of(context).pushNamedAndRemoveUntil(
                                   //      notesRoute,
                                   //      (route) => false
                                   //  );
                                   // } else {
                                   // //  email is not verifed
                                   //   Navigator.of(context).pushNamedAndRemoveUntil(
                                   //       verifyEmailRoute,
                                   //           (route) => false
                                   //   );
                                   // }
                                   // devtools.log(userCredential.toString());
                                   // Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
                                 // }
                                 // on UserNotFoundException {
                                 //   await showErrorDialog(context, "User Not Found ");
                                 // }
                                 // on WrongPasswordException {
                                 //   await showErrorDialog(context, "Wrong Credentials");
                                 // }
                                 // on GenericAuthException {
                                 //   await showErrorDialog(context, "Authentication Error");
                                 // }
                                 // catch(e) {
                                 //   await showErrorDialog(context, "Authentication Error");
                                 // }
                               },
                               child: const Text(
                                 "Login",
                                 style: TextStyle(
                                     color: Colors.blue,
                                     backgroundColor: Colors.white
                                 ),
                               ),
                             ),),

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
                default: return const CircularProgressIndicator();
             }


           }

       ),
    );
  }

}
