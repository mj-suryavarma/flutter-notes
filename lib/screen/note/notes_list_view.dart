import 'package:flutter/material.dart';
import 'package:my_notes/service/crud/could/could_note.dart';
import 'package:my_notes/utilities/dialogs/delete_dialog.dart';
import 'package:my_notes/utilities/dialogs/error_dialog.dart';
import '../../service/crud/notes_service.dart';

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
        itemCount: notes.length,
        itemBuilder: (context, index) {
          // final note = notes[index]; for local crud
          final note = notes.elementAt(index);

          return ListTile(
              onTap: () {
                onTap(note);
              },
              title: Text(
                note.text,
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            trailing: IconButton(
               onPressed: () async {
                 final shouldDelete = await showDeleteDialog(context);
                 if(shouldDelete) {
                   onDeleteNote(note);
                 }
               },
               icon: const Icon(Icons.delete),
            ) ,
          );
        });
  }
}
