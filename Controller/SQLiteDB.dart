import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BMIDatabase {
  static final BMIDatabase _instance = BMIDatabase._internal();

  factory BMIDatabase() => _instance;

  BMIDatabase._internal();

  static Database? _database;

  final String _dbName = "bitp3453_bmi";
  final String _tblName = "bmi";
  final String _colUsername = "username";
  final String _colWeight = "weight";
  final String _colHeight = "height";
  final String _colGender = "gender";
  final String _colStatus = "bmi_status";

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), '$_dbName.db');
    print('Database path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tblName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            $_colUsername TEXT,
            $_colWeight REAL,
            $_colHeight REAL,
            $_colGender TEXT,
            $_colStatus TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveBMI(String username, double weight, double height, String gender, String bmiStatus) async {
    final db = await database;
    await db.insert(
      _tblName,
      {
        _colUsername: username,
        _colWeight: weight,
        _colHeight: height,
        _colGender: gender,
        _colStatus: bmiStatus,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getPreviousBMI() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(_tblName, orderBy: 'id DESC', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}
