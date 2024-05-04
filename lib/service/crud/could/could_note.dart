import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:my_notes/service/crud/could/could_storage_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String noteTitle;
  final String noteBody;
  final String createdDate;
  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.noteTitle,
    required this.noteBody,
    required this.createdDate,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot):
        documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserFieldName],
        noteTitle = snapshot.data()[noteTitleName] as String,
        noteBody = snapshot.data()[noteBodyName] as String,
        createdDate = snapshot.data()[noteCreatedDate] as String;
}