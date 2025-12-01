import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/note.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'notes';
  static bool _initialized = false;

  static void initializeDatabaseFactory() {
    if (_initialized) return;

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      databaseFactory = databaseFactoryFfi;
    }

    _initialized = true;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'databases', 'notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            type TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertNote(Note note) async {
    final db = await database;

    return await db.insert(_tableName, note.toMap());
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query(_tableName);

    return maps.map((map) => Note.fromMap(map)).toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await database;

    return await db.update(
      _tableName,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(String id) async {
    final db = await database;

    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
