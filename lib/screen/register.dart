import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_notes/constant/routes.dart';
import 'package:my_notes/firebase_options.dart';
import 'package:my_notes/service/auth/auth_service.dart';
import 'package:my_notes/service/bloc/auth_bloc.dart';
import 'package:my_notes/service/bloc/auth_event.dart';
import 'package:my_notes/service/bloc/auth_state.dart';
import 'package:my_notes/utilities/dialogs/error_dialog.dart';
import 'dart:developer' as devtools show log;
import '../service/auth/auth-execption.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, 'Weak Password');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, 'Email already in use');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Invalid email');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Failed to register');
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Register'),
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
            backgroundColor: Colors.blue,
          ),
          body: FutureBuilder(
              future: Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              ),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('Home'),
                        titleTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                      body: Padding(
                        padding: const EdgeInsets.all((20)),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                  'Enter your email and password to see your notes'),
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
                              Center(
                                child: Column(
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        await Firebase.initializeApp(
                                          options: DefaultFirebaseOptions
                                              .currentPlatform,
                                        );
                                        final email = _email.text;
                                        final password = _password.text;
                                        // with bloc
                                        context.read<AuthBloc>().add(
                                              AuthEventRegister(
                                                  email, password),
                                            );
                                        // for leaning purpose -- without bloc
                                        // try {
                                        //   await AuthService.firebase().createUser(email: email, password: password);
                                        //   final user = AuthService.firebase().currentUser;
                                        //   await AuthService.firebase().sendEmailVerification();
                                        //   Navigator.of(context).pushNamed(verifyEmailRoute);
                                        // }
                                        // on WeakPasswordAuthException {
                                        //   devtools.log("Weak password");
                                        //   await showErrorDialog(context, "Weak Password");
                                        // }
                                        // on EmailAlreadyInUseAuthException {
                                        //   devtools.log("Email already in use");
                                        //   await showErrorDialog(context, "Email already in use");
                                        // }
                                        // on InvalidEmailAuthException {
                                        //   devtools.log("Invalid Email");
                                        //   await showErrorDialog(context, "Invalid Email");
                                        // }
                                        // on GenericAuthException catch(e) {
                                        //   devtools.log(e.toString());
                                        //   await showErrorDialog(context, "Error: ${e.toString()}");
                                        // }
                                      },
                                      child: const Text(
                                        'Register',
                                        style: TextStyle(
                                            color: Colors.blue,
                                            backgroundColor: Colors.white),
                                      ),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          // with bloc
                                          context.read<AuthBloc>().add(
                                                const AuthEventLogout(),
                                              );
                                          // without bloc
                                          // Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                                        },
                                        child: const Text(
                                            "Already register ? login here!"))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );

                  default:
                    return const Text("Loading...");
                }
              })),
    );
  }
}
