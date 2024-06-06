import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:my_notes/service/crud/could/could_storage_constants.dart';
import 'package:my_notes/service/crud/could/could_storage_exceptions.dart';

import 'could_note.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({ required String documentId}) async {
       try {
          return notes.doc(documentId).delete();
       } catch(e) {
          throw CouldNotDeleteNoteException();
       }
  }

  Future<void> updateNote({
                required String documentId,
                required String noteTitle,
                required String noteBody,
               }) async {
                  try{
                   return await notes.doc(documentId).update({noteTitleName: noteTitle, noteBodyName: noteBody});
                  } catch(e) {
                    throw CouldNotUpdateNoteException();
                  }
               }

  Stream<Iterable<CloudNote>> getAllNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then((value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)
              ));
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final dateNow = DateTime.now();
    final DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm aaa');
    final fomattedDate = formatter.format(dateNow);

    final document = await notes.add({
      ownerUserFieldName: ownerUserId,
      noteTitleName: '',
      noteBodyName: '',
      noteCreatedDate: fomattedDate.toString(),
    });
    final fetchedNote = await document.get();
    return CloudNote(
        documentId: fetchedNote.id,
        ownerUserId: ownerUserId,
        noteTitle: '',
        noteBody: '',
        createdDate: fomattedDate,
    );
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  FirebaseCloudStorage._sharedInstance();

  factory FirebaseCloudStorage() => _shared;
}
