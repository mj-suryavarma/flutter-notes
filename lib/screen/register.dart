import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notes/firebase_options.dart';

class RegisterView extends StatefulWidget  {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>{

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
          title: const Text('Register'),
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 25
          ),
          backgroundColor: Colors.blue ,
        ),
        body: FutureBuilder(
            future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            ),
            builder: (context, snapshot) {
              switch(snapshot.connectionState) {
                case ConnectionState.done:
                  return  Container(
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
                                    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                        email: email, password: password
                                    );
                                    print(userCredential);
                                  } on FirebaseAuthException catch(e) {
                                    print(e);
                                  }
                                },
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      backgroundColor: Colors.white
                                  ),
                                ),
                              )
                            ],
                          )
                      )

                  );

                default: return Text("Loading...");
              }


            }

        )

    );
  }
}
