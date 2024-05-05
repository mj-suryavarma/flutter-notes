import 'package:flutter/material.dart';
import 'package:my_notes/constant/app_color.dart';
import 'package:my_notes/service/crud/could/could_note.dart';
import 'package:my_notes/utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);
class NotesListView extends StatelessWidget {

  // final List<DatabaseNotes> notes;  for local crud
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
              Key? key,
              required this.notes,
              required this.onDeleteNote,
              required this.onTap,
                  }) : super(key: key);



  @override
  Widget build(BuildContext context) {

    return ListView.builder(
         padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          // final note = notes[index]; for local crud
          final note = notes.elementAt(index);

          return ListTile(
            tileColor: Colors.white54,
            splashColor: Colors.white70,
            minVerticalPadding: 5,
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            iconColor: Colors.blue.shade300,
              onTap: () {
                onTap(note);
              },
              title: Text(
                note.noteTitle,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 18
                ),
              ),
            subtitle: Column(
             mainAxisAlignment: MainAxisAlignment.start,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const SizedBox(
                 height: 10,
               )
               ,Text(
                   note.noteBody,
                   softWrap: true,
                   overflow: TextOverflow.ellipsis,
                  ),
               Text(
                 note.createdDate,
                 textAlign: TextAlign.start,
               )
                ]
              ),
            trailing: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                IconButton(
                  alignment: Alignment.bottomRight,
                  color: Colors.greenAccent,
                  iconSize: 20,
                  onPressed: () async {
                    final shouldDelete = await showDeleteDialog(context);
                    if(shouldDelete) {
                      onDeleteNote(note);
                    }
                  },
                  icon: const Icon(Icons.delete_rounded),
                ) ,
              ],

            )

          
          );
        });
  }
}
