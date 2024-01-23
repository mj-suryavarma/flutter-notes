import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_notes/constant/routes.dart';
import 'package:my_notes/firebase_options.dart';
import 'package:my_notes/screen/login.dart';
import 'package:my_notes/screen/note/create_update_note_view.dart';
import 'package:my_notes/screen/note/notes_view.dart';
import 'package:my_notes/screen/register.dart';
import 'package:my_notes/screen/verify.dart';
import 'dart:developer' as devtool show log;
import 'package:bloc/src/bloc.dart';
import 'package:my_notes/service/auth/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'MJ Notes App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute : (context) => const RegisterView(),
        notesRoute : (context) => const NotesView(),
        verifyEmailRoute : (context) => const EmailVerifyView(),
        createOrUpdateNoteRoute : (context) => const CreateUpdateNoteView(),
      },
    );
  }

}

// class HomePage extends StatelessWidget {
//   const HomePage({Key? key}): super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body:  FutureBuilder(
//           future: AuthService.firebase().initialize(),
//           builder: (context, snapshot) {
//             switch(snapshot.connectionState) {
//          case ConnectionState.done:
//               final user = AuthService.firebase().currentUser;
//               if(user != null) {
//                   if(user.isEmailVerified) {
//                      devtool.log("Email is Verified");
//                      return NotesView();
//                   } else {
//                       return EmailVerifyView();
//                   }
//               }
//                else  return LoginView();
//
//             default: return Text("Loading...");
//             }
//           }
//
//       ),
//     );
//   }
// }

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Testing Bloc")),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state) {
            _controller.clear();
          },
          builder: (context, state) {
            final invalidValue = (state is CounterStateInvalidNumber) ? state.invalidValue : '';
            return Column(
              children: [
                Text('Current value => ${state.value}'),
                Visibility(
                  visible: state is CounterStateInvalidNumber,
                  child: Text('Invalid input $invalidValue'),
                ),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter a number here'
                  ),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          context
                              .read<CounterBloc>()
                              .add(DecrementEvent(_controller.text));
                        },
                        child: const Text('-')
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<CounterBloc>()
                            .add(IncrementEvent(_controller.text));
                      },
                      child: const Text('+'),
                    )
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState {
  final int value;
  const CounterState(this.value);
}

class CounterStateValid extends CounterState {
   const CounterStateValid(int value): super(value);
}

class CounterStateInvalidNumber extends CounterState {
  final String invalidValue;
  const CounterStateInvalidNumber({
    required this.invalidValue,
    required int previousValue,
  }): super(previousValue);
}

abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(super.value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(super.value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc(): super(const CounterStateValid(0)) {
    on<IncrementEvent>((event, emit) {
      final integer = int.tryParse(event.value);
      if(integer == null) {
        emit(
          CounterStateInvalidNumber(
              invalidValue: event.value,
              previousValue: state.value)
        );
      } else {
        emit(
          CounterStateValid(state.value + integer),
        );
      }
    });

    on<DecrementEvent>((event, emit) {

    });
  }

}