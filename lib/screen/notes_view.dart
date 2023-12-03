import 'package:flutter/material.dart';
import 'package:my_notes/service/auth/auth_service.dart';
import '../constant/routes.dart';
import '../enums/menu_action.dart';
import 'dart:developer' as devtool show log;

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome!, Main Ui"),
        backgroundColor: Colors.lightBlue,
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch(value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                devtool.log(shouldLogout.toString());
                if(shouldLogout) {
                  await AuthService.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                          (_) => false
                  );
                }
                break;
            }
          },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text("Log out"),
                )
              ];
            },)
        ],
      ),
    );
  }
}


Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(context: context, builder: (context) {
    return AlertDialog(
        title: const Text("Sign out"),
        content: const Text("Are you sure want to sign out"),
        actions: [
          TextButton(onPressed: () {
            Navigator.of(context).pop(false);
          }, child: const Text("Cancel")),

          TextButton(onPressed: () {
            Navigator.of(context).pop(true);
          }, child: const Text("Log out"))
        ]
    );
  }).then((value) =>  value ?? false);
}