import 'package:flutter/material.dart';
import 'package:my_notes/service/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;

  Future<DatabaseNotes> updateNote({required DatabaseNotes note, required String text}) async {
        final db = _getDatabaseOrThrow();
        await getNote(id: note.id);

        final updateCount = await db.update(notesTable, {
          textColumn: text,
          isSyncedWithCloudColumn: 0
        });

        if(updateCount == 0) {
          throw CouldNotUpdateNoteException();
        } else  {
          return await getNote(id: note.id);
        }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable);

     return notes.map((n) => DatabaseNotes.fromRow(n));
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable, limit: 1, where: 'id = ?', whereArgs: [id]);
    if(notes.isEmpty) {
        throw CouldNotFindNoteException();
    }
    else {
      return DatabaseNotes.fromRow(notes.first);
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(notesTable);
  }
  Future<void> deleteNote({ required int id }) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(notesTable,
        where: 'id = ?',
        whereArgs: [id]);
    if(deleteCount == 0) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    //make sure owner exist in db
    final dbUser = await getUser(email: owner.email);
    if(dbUser != owner) {
      throw CouldNotFindUserException();
    }

    const text = "";

  //  create new notes
    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1
    });

    final note = DatabaseNotes(id: noteId, userId: owner.id, text: text, isSyncedWithCloud: true);

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async  {
    final db = _getDatabaseOrThrow();
    final results  = await db.query(userTable, limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if(results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
                    where: 'email = ?', limit: 1 ,
                    whereArgs: [email.toLowerCase()]
                  );
    if(results.isNotEmpty) {
        throw UserAlreadyExistException();
    }

    final userId = await db.insert(userTable, {
        emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteuser({ required String email }) async {
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
      final db = await openDatabase(dbPath);
      _db = db;

            //  create user table
            await db.execute(createUserTable);
            // create Notes table
            await db.execute(createNoteTable);

    } on MissingPlatformDirectoryException {

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
  final String text;
  final bool isSyncedWithCloud;

   const DatabaseNotes({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
    });

   DatabaseNotes.fromRow(Map<String, Object?> map) : id = map[idColumn] as int,
                userId = map[userIdColumn] as int, text = map[textColumn] as String,
                isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

   @override
   String toString()  => 'id = $id, userId = $userId, text $text, isSyncedWithCloud = $isSyncedWithCloud';


  @override
  int get hasCode => id.hashCode;
 }

const dbName = "notes.db";
const notesTable = "note";
const userTable = "user";
const idColumn = "id";
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncedWithCloudColumn = "is_synced_with_cloud";
const emailColumn = "email";


const createUserTable  =  ''' CREATE TABLE IF NOT EXIST "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );  ''';

const createNoteTable = '''CREATE TABLE IF NOT EXIST "notes" (
                  "id"	INTEGER NOT NULL,
                  "user_id"	INTEGER NOT NULL,
                  "text"	TEXT NOT NULL,
                  "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
                  FOREIGN KEY("user_id") REFERENCES "user",
                  PRIMARY KEY("id" AUTOINCREMENT)
                );
            ''';