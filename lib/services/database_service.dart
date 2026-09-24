import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/session.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance =
      DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    final dir = await getDatabasesPath();

    final path = p.join(
      dir,
      'camera_share.db',
    );

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            role TEXT NOT NULL,
            address TEXT NOT NULL,
            port INTEGER NOT NULL,
            started_at TEXT NOT NULL,
            ended_at TEXT
          )
        ''');
      },
    );

    return _db!;
  }

  Future<int> insertSession(
    CameraSession session,
  ) async {
    final db = await database;

    final values =
        Map<String, Object?>.from(
          session.toMap(),
        )..remove('id');

    return db.insert(
      'sessions',
      values,
    );
  }

  Future<List<CameraSession>> getSessions() async {
    final db = await database;

    final rows = await db.query(
      'sessions',
      orderBy: 'started_at DESC',
    );

    return rows
        .map(CameraSession.fromMap)
        .toList();
  }

  Future<void> clearSessions() async {
    final db = await database;

    await db.delete(
      'sessions',
    );
  }
}
