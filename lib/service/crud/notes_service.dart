import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_notes/extensions/filter.dart';
import 'package:my_notes/service/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;

  List<DatabaseNotes> _notes = [];

  DatabaseUser? _user;

  late final StreamController<List<DatabaseNotes>> _notesStreamController;

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
     _notesStreamController = StreamController<List<DatabaseNotes>>.broadcast(
       onListen: () {
         _notesStreamController.sink.add(_notes);
       }
     );
  }
  factory NotesService() => _shared;

  Stream<List<DatabaseNotes>> get allNotes => _notesStreamController.stream.filter((note) {
    final currentUser = _user;
    if(currentUser != null) {
      return note.userId == currentUser.id;
    } else {
      throw UserShouldBeSetBeforeAccessingNoteService();
    }
  });

  Future<void> _ensureDbIsOpen() async {
    try{
      await open();
    } catch(e) {
        //
    }
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    await _ensureDbIsOpen();
    bool setCurrentUser = true;
    try {
      final user = await getUser(email: email);
      if(setCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUserException {
      final createdUser = await createUser(email: email);
      if(setCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    }
    catch(e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    await _ensureDbIsOpen();
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNotes> updateNote({required DatabaseNotes note, required String text}) async {
        await _ensureDbIsOpen();
        final db = _getDatabaseOrThrow();
        await getNote(id: note.id);

        final updateCount = await db.update(notesTable, {
          noteTitleColumn: text,
          isSyncedWithCloudColumn: 0
        }, where: 'id = ?', whereArgs: [note.id]);

        if(updateCount == 0) {
          throw CouldNotUpdateNoteException();
        } else  {
          final updateNote = await getNote(id: note.id);
          _notes.removeWhere((item) => item.id == updateNote.id);
          _notes.add(updateNote);
          _notesStreamController.add(_notes);
          return updateNote;
        }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable);

     return notes.map((n) => DatabaseNotes.fromRow(n));
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable, limit: 1, where: 'id = ?', whereArgs: [id]);
    if(notes.isEmpty) {
        throw CouldNotFindNoteException();
    }
    else {
      final note = DatabaseNotes.fromRow(notes.first);
      _notes.removeWhere((item) => item.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(notesTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }

  Future<void> deleteNote({ required int id }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(notesTable,
        where: 'id = ?',
        whereArgs: [id]);
    if(deleteCount == 0) {
      throw CouldNotDeleteUserException();
    } else {
      _notes.removeWhere((item) => item.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure owner exists in db
    final dbUser = await getUser(email: owner.email);
    if(dbUser != owner) {
      throw CouldNotFindUserException();
    }

    const noteTitle = "note_title";
    const noteBody = "note_body";

  //  create new notes
    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      noteTitleColumn: noteTitle,
      noteTitleColumn: noteBody,
      isSyncedWithCloudColumn: 1
    });

    final note = DatabaseNotes(id: noteId, userId: owner.id, noteTitle: noteTitle, noteBody: noteBody, isSyncedWithCloud: true);

    _notes.add(note);
    _notesStreamController.add(_notes);
    print('notes: $note');

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async  {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results  = await db.query(userTable, limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if(results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
                    where: 'email = ?', limit: 1 ,
                    whereArgs: [email.toLowerCase()]
                  );
    if(results.isNotEmpty) {
        throw UserAlreadyExistsException();
    }

    final userId = await db.insert(userTable, {
        emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({ required String email }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(userTable,
                        where: 'email = ?',
                        whereArgs: [email.toLowerCase()]);
    if(deleteCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Database _getDatabaseOrThrow () {
      final db = _db;
      if(db == null) {
        throw DatabaseNotOpenException();
      } else {
        return db;
      }
  }

  Future<void> close() async {
    await _ensureDbIsOpen();
    final db = _db;
    if(db == null) {
      throw DatabaseNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if(_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      print("db path here -----   $dbPath, here is docu name - $docsPath");
      final db = await openDatabase(dbPath);
      _db = db;

            //  create user tables
            await db.execute(createUserTable);
            // create Notes table
            await db.execute(createNoteTable);
            await _cacheNotes();
    } on MissingPlatformDirectoryException {
        throw MissingPlatformDirectoryException("");
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
   required this.id,
   required this.email
  });

  DatabaseUser.fromRow(Map<String, Object?> map) : id = map[idColumn] as int, email = map[emailColumn] as String;

  @override
  String toString () => 'Persion, ID = $id, email = $email';

  @override
  bool operator == (covariant DatabaseUser other) => id == other.id;

  @override
  int get hasCode => id.hashCode;
}
 class DatabaseNotes {
  final int id;
  final int userId;
  final String noteTitle;
  final String noteBody;
  final bool isSyncedWithCloud;

   const DatabaseNotes({
    required this.id,
    required this.userId,
    required this.noteTitle,
    required this.noteBody,
    required this.isSyncedWithCloud,
    });

   DatabaseNotes.fromRow(Map<String, Object?> map) : id = map[idColumn] as int,
                userId = map[userIdColumn] as int, noteTitle = map[noteTitleColumn] as String,
                noteBody = map[noteBodyColumn] as String,
                isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

   @override
   String toString()  => 'id = $id, userId = $userId, text $noteTitle, isSyncedWithCloud = $isSyncedWithCloud';


  @override
  int get hasCode => id.hashCode;
 }

const dbName = "notes.db";
const notesTable = "notes";
const userTable = "user";
const idColumn = "id";
const userIdColumn = "user_id";
const noteTitleColumn = "note_title";
const noteBodyColumn = "note_body";
const isSyncedWithCloudColumn = "is_synced_with_cloud";
const emailColumn = "email";


const createUserTable  =  ''' CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );  ''';

const createNoteTable = '''CREATE TABLE IF NOT EXISTS "notes" (
                  "id"	INTEGER NOT NULL,
                  "user_id"	INTEGER NOT NULL,
                  "note_title"	TEXT NOT NULL,
                  "note_body" TEXT NOT NULL
                  "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
                  FOREIGN KEY("user_id") REFERENCES "user",
                  PRIMARY KEY("id" AUTOINCREMENT)
                );
            ''';