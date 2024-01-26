import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_notes/constant/routes.dart';
import 'package:my_notes/service/auth/auth_service.dart';
import 'package:my_notes/service/bloc/auth_bloc.dart';
import 'package:my_notes/service/bloc/auth_event.dart';

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
                      onPressed: () async {
                        //with bloc
                         context.read<AuthBloc>().add(
                           const AuthEventSendEmailVerification(),
                         );
                        //without bloc
                        // await AuthService.firebase().sendEmailVerification();
                      },
                      child: const Text("send email verification")),

                  TextButton(onPressed: () async {
                    //  with bloc
                    context.read<AuthBloc>().add(
                        const AuthEventLogout(),
                    );
                    // without bloc
                    // await AuthService.firebase().logOut();
                    // Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
                  }, child: const Text("Restart"))
                ],
              ),
            )
        )
    );
  }
}