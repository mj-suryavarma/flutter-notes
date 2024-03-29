import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_notes/constant/app_color.dart';
import 'package:my_notes/service/bloc/auth_bloc.dart';
import 'package:my_notes/service/bloc/auth_event.dart';
import 'package:my_notes/service/bloc/auth_state.dart';
import 'package:my_notes/utilities/dialogs/error_dialog.dart';
import 'package:my_notes/utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgetPassword) {
          if (state.hasSendEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            await showErrorDialog(
                context,
                'We could not process your request, Please make sure that you are a register user, if not register now and go back one step'
            );
          }
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              const Text(
                "Forgot Password",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(appThemeColor)),
              ),
              const SizedBox(height: 20),
              const Text(
                  'If you forgot password, simply enter you email, we will send link to email',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                    fontFamily: 'cursive'
                  ),
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                controller: _controller,
                decoration: const InputDecoration(
                    hintText: 'Your email address...'
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(onPressed: () {
                  final email = _controller.text;
                  context
                      .read<AuthBloc>()
                      .add(AuthEventForgetPassword(email: email));
              }, child:
              const Text(
                'Send me to password reset link',
                style: TextStyle(
                  color: Colors.blue,
                ),
              )
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(onPressed: () {
                context
                    .read<AuthBloc>()
                    .add(const AuthEventLogout());
              }, child: const Text(
                  'Back to login page',
                  style: TextStyle(
                  color: Colors.blue,
                  ),
              )
              )
            ],
          ),
        ),
      ),
    );
  }
}
