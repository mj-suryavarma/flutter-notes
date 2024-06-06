import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_notes/constant/assert.dart';
import 'package:my_notes/constant/text_decoration.dart';
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
  late final TextEditingController _textTitleController;
  late final TextEditingController _textBodyController;

  @override
  initState() {
    _notesService = FirebaseCloudStorage();
    _textTitleController = TextEditingController();
    _textBodyController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final noteTitle = _textTitleController.text;
    final noteBody = _textBodyController.text;
    await _notesService.updateNote(documentId: note.documentId, noteTitle: noteTitle, noteBody: noteBody);
  }

  void _setupTextControllerListener() async {
    _textTitleController.removeListener(_textControllerListener);
    _textBodyController.removeListener(_textControllerListener);
    _textTitleController.addListener(_textControllerListener);
    _textBodyController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNotes = context.getArgument<CloudNote>();
    if (widgetNotes != null) {
      _note = widgetNotes;
      _textTitleController.text = widgetNotes.noteTitle;
      _textBodyController.text = widgetNotes.noteBody;
      return widgetNotes;
    }

    final existingNote = _note;
    if (existingNote != null) {
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
    if (_textTitleController.text.isEmpty && _note != null) {
      await _notesService.deleteNote(documentId: _note!.documentId);
    }
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final textTitle = _textTitleController.text;
    final textBody = _textBodyController.text;
    if (note != null && textTitle.isNotEmpty && textBody.isNotEmpty) {
      await _notesService.updateNote(documentId: note.documentId, noteTitle: textTitle, noteBody: textBody);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textTitleController.dispose();
    _textBodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image(
          image: AssetImage(Assets.mjNotes),
          height: 70,
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () async {
                final text = _textTitleController.text;
                if (_note == null || text.isEmpty) {
                  return showCannotShareEmptyNoteDialog(context);
                } else {
                  Share.share(text);
                }
              },
              color: Colors.green,
              icon: const Icon(Icons.share_sharp)),

          IconButton(onPressed: () {
                  Navigator.pop(context);
              },
              color: Colors.green,
              icon: const Icon(Icons.arrow_back_sharp),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // if(snapshot.hasData) _notes = snapshot.data as DatabaseNotes;
              _setupTextControllerListener();
              return Container(
                margin: const EdgeInsets.all((15)),
                child: Column(
              children: [
                TextField(
                  controller: _textTitleController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: AppCustomDecoration().appDefualtDecoration(),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _textBodyController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 20,
                  decoration: AppCustomDecoration().appDefualtDecoration(),
                )
          ],
          )
              );

            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}
