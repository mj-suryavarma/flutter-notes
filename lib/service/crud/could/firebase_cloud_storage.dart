import 'package:cloud_firestore/cloud_firestore.dart';
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
                required String text
               }) async {
                  try{
                   return await notes.doc(documentId).update({textFieldName: text});
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
          .then((value) => value.docs.map((doc) {
                return CloudNote(
                    documentId: doc.id,
                    ownerUserId: doc.data()[ownerUserFieldName] as String,
                    text: doc.data()[textFieldName] as String);
              }));
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  void createNewNote({required String ownerUserId}) async {
    await notes.add({
      ownerUserFieldName: ownerUserId,
      textFieldName: '',
    });
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  FirebaseCloudStorage._sharedInstance();

  factory FirebaseCloudStorage() => _shared;
}
