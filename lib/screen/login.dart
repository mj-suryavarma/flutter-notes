import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_notes/constant/app_color.dart';
import 'package:my_notes/constant/assert.dart';
import 'package:my_notes/constant/routes.dart';
import 'package:my_notes/firebase_options.dart';
import 'package:my_notes/service/auth/auth-execption.dart';
import 'package:my_notes/service/auth/auth_service.dart';
import 'package:my_notes/service/bloc/auth_bloc.dart';
import 'package:my_notes/service/bloc/auth_event.dart';
import 'package:my_notes/service/bloc/auth_state.dart';
import 'dart:developer' as devtools show log;
import 'package:my_notes/utilities/dialogs/error_dialog.dart';
import 'package:my_notes/utilities/dialogs/loading_dialog.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundException) {
          await showErrorDialog(context, "Cannot find a user");
          } else if (state.exception is WrongPasswordException) {
             await showErrorDialog(context, "Wrong Credentials");
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, "Authentication Error Occurred");
          }
        }
      },
      child: Scaffold(
        body: FutureBuilder(
            future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            ),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return Padding(
                      padding: const EdgeInsets.all((30)),
                      child: SingleChildScrollView(
                          child: Column(
                        children: [
                          Image(
                            image: AssetImage(Assets.mjNotes),
                            height: 100,
                            width: double.infinity,
                          )
                          ,
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                              style: TextStyle(
                                color: Colors.black,

                              ),
                              'Please log in to your account in order to interact with and create notes!'),
                          TextField(
                            autofocus: true,
                            controller: _email,
                            decoration: const InputDecoration(
                                hintText: 'Enter your email here'),
                          ),
                          TextField(
                            controller: _password,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: const InputDecoration(
                                hintText: 'Enter your password here'),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextButton(
                             style: TextButton.styleFrom(
                               padding: const EdgeInsets.all(10),
                               backgroundColor: Color(appThemeColor),

                             ),
                            onPressed: () async {
                              await AuthService.firebase().initialize();
                              final email = _email.text;
                              final password = _password.text;
                              //with bloc
                              context.read<AuthBloc>().add(
                                    AuthEventLogin(email, password),
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
                                  color: Colors.white,
                                  backgroundColor: Color(appThemeColor),
                                  fontSize: 20,
                                 fontFamily: 'cursive',
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),

                          TextButton(
                            style: TextButton.styleFrom(

                            ),
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                  const AuthEventForgetPassword(),
                                );
                              },
                              child: const Text(
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                                  "I forgot my password")

                          ),
                         const SizedBox(
                            height: 15,
                          ),
                          TextButton(
                              onPressed: () {
                                // with bloc
                                context.read<AuthBloc>().add(
                                  const AuthEventShouldRegister(),
                                );
                                // without bloc
                                // Navigator.of(context).pushNamedAndRemoveUntil(
                                //     registerRoute, (route) => false);
                              },
                              child: const Text(
                                  style: TextStyle(
                                color: Colors.blue,
                              ),
                                  "Not register yet ? register here!"))
                        ],
                      )));

                  return const Text("Done");
                // default: return Text("Loading...");
                default:
                  return const CircularProgressIndicator();
              }
            }),
      ),
    );
  }
}
