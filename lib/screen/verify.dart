import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_notes/constant/routes.dart';

class EmailVerifyView extends StatefulWidget {
  const EmailVerifyView({Key? key}): super(key: key);

  @override
  _EmailVerifyViewState createState() => _EmailVerifyViewState();
}

class _EmailVerifyViewState extends State<EmailVerifyView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white70,
        appBar: AppBar(
          title: const Text("Verify Email"),
          titleTextStyle: const TextStyle(
          color: Colors.blue,
          fontSize: 25,
        ),
        ),
        body: Container(
            margin: EdgeInsets.all((30)),
            child:  Center(
              child: Column(
                children: [
                  const Text("We've sent you an email verification. Please open it to verify your account"),
                  const Text("If you haven't received a verification email yet, press the button below"),
                  const Text("Please verify your email address:"),
                  TextButton(
                      onPressed: () {
                        final user = FirebaseAuth.instance.currentUser;
                        user?.sendEmailVerification();
                      },
                      child: const Text("send email verification")),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil('/login/', (route) => false);
                      },
                      child: const Text("Go to login >>")
                  ),
                  TextButton(onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
                  }, child: const Text("Restart"))
                ],
              ),
            )
        )
    );
  }
}