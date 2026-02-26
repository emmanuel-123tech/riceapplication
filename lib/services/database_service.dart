import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/app_models.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'rice_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE user_profile(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            role TEXT NOT NULL,
            organisation TEXT,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE scans(
            id TEXT PRIMARY KEY,
            created_at TEXT NOT NULL,
            rice_type TEXT NOT NULL,
            img1_path TEXT NOT NULL,
            img2_path TEXT NOT NULL,
            selected_path TEXT NOT NULL,
            result_json TEXT NOT NULL,
            model_version TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> saveUser(UserProfile profile) async {
    final database = await db;
    await database.delete('user_profile');
    await database.insert('user_profile', profile.toMap());
  }

  Future<UserProfile?> getUser() async {
    final database = await db;
    final rows = await database.query('user_profile', orderBy: 'id DESC', limit: 1);
    if (rows.isEmpty) return null;
    return UserProfile.fromMap(rows.first);
  }

  Future<void> insertScan(ScanRecord record) async {
    final database = await db;
    await database.insert('scans', record.toMap());
    await _trimScans(database);
  }

  Future<void> _trimScans(Database database) async {
    final rows = await database.query('scans', columns: ['id'], orderBy: 'created_at DESC');
    if (rows.length <= 100) return;
    final deleteIds = rows.skip(100).map((e) => e['id']).toList();
    final placeholders = List.filled(deleteIds.length, '?').join(',');
    await database.delete('scans', where: 'id IN ($placeholders)', whereArgs: deleteIds);
  }

  Future<List<ScanRecord>> getRecentScans() async {
    final database = await db;
    final rows = await database.query('scans', orderBy: 'created_at DESC', limit: 100);
    return rows.map(ScanRecord.fromMap).toList();
  }
}
