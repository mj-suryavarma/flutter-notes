import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerifyView extends StatefulWidget {
  const EmailVerifyView({Key? key}): super(key: key);

  @override
  _EmailVerifyViewState createState() => _EmailVerifyViewState();
}

class _EmailVerifyViewState extends State<EmailVerifyView> {
  @override
  Widget build(BuildContext context) {
    return  Container(
        margin: EdgeInsets.all((30)),
        child:  Center(
        child: Column(
      children: [
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
        )
      ],
        ),
     )
    );
  }
}