import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_notes/service/auth/auth_service.dart';

import '../../service/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({Key? key}) : super(key: key);

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
 DatabaseNotes? _notes;
 late final NotesService _notesService;
 late final TextEditingController _textController;

   @override
   initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
     super.initState();
   }

   void _setupTextControllerListener() async {
     _textController.removeListener(_textControllerListener);
     _textController.addListener(_textControllerListener);
   }
   
   void _textControllerListener() async {
      final note = _notes;
      if(note == null) {
        return;
      }
      final text = _textController.text;
      await _notesService.updateNote(
          note: note,
          text: text);
   }

  Future<DatabaseNotes> createNewNote() async {
      final existingNote = _notes;
      if(existingNote != null) {
          return existingNote;
      }
      final currentUser = AuthService.firebase().currentUser!;
      final email = currentUser.email!;

      final owner = await _notesService.getUser(email: email);
      return await _notesService.createNote(owner: owner);
  }

  void _deleteNoteIfTextIsEmpty() async {
     if(_textController.text.isEmpty &&  _notes != null) {
        await _notesService.deleteNote(id: _notes!.id);
     }
  }

  void _saveNoteIfTextIsNotEmpty() async {
       final note = _notes;
       final text = _textController.text;
       if(note != null && text.isNotEmpty) {
         await _notesService.updateNote(
             note: note,
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
           backgroundColor: Colors.lightBlue,,
       ),
        body: FutureBuilder(
          future: createNewNote(),
          builder: (context, snapshot) {
              switch(snapshot.connectionState) {
                case ConnectionState.done:
                  _notes = snapshot.data;
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
