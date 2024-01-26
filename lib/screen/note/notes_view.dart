import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_notes/screen/note/notes_list_view.dart';
import 'package:my_notes/service/auth/auth_service.dart';
import 'package:my_notes/service/bloc/auth_bloc.dart';
import 'package:my_notes/service/bloc/auth_event.dart';
import 'package:my_notes/service/crud/could/could_note.dart';
import 'package:my_notes/service/crud/could/firebase_cloud_storage.dart';
import '../../constant/routes.dart';
import '../../enums/menu_action.dart';
import 'dart:developer' as devtool show log;
import '../../service/crud/notes_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

// DatabaseNotes  -- for local crud -- now have been replaced with CloudNote
// NoteService -- for local crud -- now have been replaced with FirebaseCloudStorage
class _NotesViewState extends State<NotesView> {

  late final FirebaseCloudStorage _notesService;
  // String get userEmail => AuthService.firebase().currentUser!.email ?? ''; for local crud
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome!, Main Ui"),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(onPressed: () {
             Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
          },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch(value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                devtool.log(shouldLogout.toString());
                if(shouldLogout) {
                  // with bloc
                   context.read<AuthBloc>().add(
                     const AuthEventLogout(),
                   );
                   // without bloc
                  // await AuthService.firebase().logOut();
                  // Navigator.of(context).pushNamedAndRemoveUntil(
                  //     loginRoute,
                  //         (_) => false
                  // );
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
      body: StreamBuilder(
          stream: _notesService.getAllNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            print("snapshot data is here $snapshot here is snapshot.connectionState ${snapshot.connectionState}");
            switch(snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Text("Waiting for all notes");
              case ConnectionState.done || ConnectionState.values || ConnectionState.active:
                if(snapshot.hasData) {
                  //DatabaseNotes return type for local crud
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  print(allNotes);
                  devtool.log(allNotes.toString());
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(documentId: note.documentId);
                    },
                    onTap: (note) {
                      Navigator.of(context).pushNamed(
                          createOrUpdateNoteRoute,
                          arguments: note
                      );
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              default:
                return Text("Here is Default Text");
            }
          }),
      // return this for local crud
      // body: FutureBuilder(
      //   future: _notesService.getOrCreateUser(email: userEmail),
      //   builder: (context, snapshot){
      //     switch(snapshot.connectionState) {
      //       case ConnectionState.done:
      //         return StreamBuilder(
      //             stream: _notesService.allNotes,
      //             builder: (context, snapshot) {
      //               print("snapshot data is here $snapshot here is snapshot.connectionState ${snapshot.connectionState}");
      //                switch(snapshot.connectionState) {
      //                  case ConnectionState.waiting:
      //                    return const Text("Waiting for all notes");
      //                  case ConnectionState.done || ConnectionState.values || ConnectionState.active:
      //                    if(snapshot.hasData) {
      //                      //DatabaseNotes return type for local crud
      //                      final allNotes = snapshot.data as Iterable<CloudNote>;
      //                      print(allNotes);
      //                      devtool.log(allNotes.toString());
      //                      return NotesListView(
      //                        notes: allNotes,
      //                        onDeleteNote: (note) async {
      //                          await _notesService.deleteNote(id: note.id);
      //                       },
      //                       onTap: (note) {
      //                         Navigator.of(context).pushNamed(
      //                           createOrUpdateNoteRoute,
      //                           arguments: note
      //                         );
      //                       },
      //                      );
      //                    } else {
      //                      return const CircularProgressIndicator();
      //                    }
      //                  default:
      //                    return Text("Here is Default Text");
      //                }
      //             });
      //       default:
      //        return const CircularProgressIndicator();
      //     }
      //   },
      // ),
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