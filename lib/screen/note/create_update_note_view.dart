import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_notes/service/auth/auth_service.dart';
import 'package:my_notes/utilities/generics/getArgument.dart';
import '../../service/crud/notes_service.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
 DatabaseNotes? _note;
 late final NotesService _notesService;
 late final TextEditingController _textController;

   @override
   initState() {
    _notesService = NotesService();
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
       note: note,
       text: text);
   print("New Notes are updated --- note ; ${note}, text: ${text}");
 }

 void _setupTextControllerListener() async {
     _textController.removeListener(_textControllerListener);
     _textController.addListener(_textControllerListener);
   }

  Future<DatabaseNotes> createOrGetExistingNote(BuildContext context) async {
      final widgetNotes = context.getArgument<DatabaseNotes>();
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
      final email = currentUser.email!;
      final owner = await _notesService.getUser(email: email);
      final createdNote = await _notesService.createNote(owner: owner);
      _note = createdNote;
      return createdNote;
  }

  void _deleteNoteIfTextIsEmpty() async {
     if(_textController.text.isEmpty &&  _note != null) {
        await _notesService.deleteNote(id: _note!.id);
     }
  }

  void _saveNoteIfTextIsNotEmpty() async {
       final note = _note;
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
           backgroundColor: Colors.lightBlue,
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
