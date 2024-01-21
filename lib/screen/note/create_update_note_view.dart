import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_notes/service/auth/auth_service.dart';
import 'package:my_notes/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:my_notes/utilities/generics/getArgument.dart';
import 'package:share_plus/share_plus.dart';
import '../../service/crud/notes_service.dart';
import 'package:my_notes/service/crud/could/could_note.dart';
import 'package:my_notes/service/crud/could/could_storage_exceptions.dart';
import 'package:my_notes/service/crud/could/firebase_cloud_storage.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

// DatabaseNotes  -- for local crud -- now have been replaced with CloudNote
// NoteService -- for local crud -- now have been replaced with FirebaseCloudStorage
class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
 CloudNote? _note;
 late final FirebaseCloudStorage _notesService;
 late final TextEditingController _textController;

   @override
   initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
     super.initState();
   }


 void _textControllerListener() async {
   final note = _note;
   if(note == null) {
   return;
   }
   final text = _textController.text;
   await _notesService.updateNote(
       documentId: note.documentId,
       text: text);
 }

 void _setupTextControllerListener() async {
     _textController.removeListener(_textControllerListener);
     _textController.addListener(_textControllerListener);
   }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
      final widgetNotes = context.getArgument<CloudNote>();
      if(widgetNotes != null) {
        _note = widgetNotes;
        _textController.text = widgetNotes.text;
        return widgetNotes;
      }

      final existingNote = _note;
      if(existingNote != null) {
          return existingNote;
      }
      final currentUser = AuthService.firebase().currentUser!;
      final email = currentUser.email;
      //these things for local crud functionality
      // final owner = await _notesService.getUser(email: email);
      // final createdNote = await _notesService.createNote(owner: owner);
      final userId = currentUser.id;
      final createdNote = await _notesService.createNewNote(ownerUserId: userId);
      _note = createdNote;
      return createdNote;
  }

  void _deleteNoteIfTextIsEmpty() async {
     if(_textController.text.isEmpty &&  _note != null) {
        await _notesService.deleteNote(documentId: _note!.documentId);
     }
  }

  void _saveNoteIfTextIsNotEmpty() async {
       final note = _note;
       final text = _textController.text;
       if(note != null && text.isNotEmpty) {
         await _notesService.updateNote(
             documentId: note.documentId,
             text: text
         );
       }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar:  AppBar(
         title: const Text("Create New Note"),
           backgroundColor: Colors.lightBlue,
           actions: [
             IconButton(
                 onPressed: () async {
                   final text = _textController.text;
                   if(_note == null || text.isEmpty) {
                     return showCannotShareEmptyNoteDialog(context);
                   }
                   else {
                      Share.share(text);
                   }
                 },
                 icon: const Icon(Icons.share_sharp))
           ],
       ),
        body: FutureBuilder(
          future: createOrGetExistingNote(context),
          builder: (context, snapshot) {
              switch(snapshot.connectionState) {
                case ConnectionState.done:
                  // if(snapshot.hasData) _notes = snapshot.data as DatabaseNotes;
                  _setupTextControllerListener();
                  return TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                       hintText: 'Start typing your text here...'
                    ),
                  );
                default:
                   return CircularProgressIndicator();
              }
          },
        ),
    );
  }
}
