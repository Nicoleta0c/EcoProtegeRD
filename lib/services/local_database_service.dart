import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LocalDatabaseService {
  static Database? _database;
  static const String _databaseName = 'eco_protege_rd.db';
  static const int _databaseVersion = 1;

  // Tabla de reportes
  static const String _tableReports = 'reports';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableReports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        foto TEXT NOT NULL,
        latitud REAL NOT NULL,
        longitud REAL NOT NULL,
        fecha_creacion TEXT NOT NULL,
        usuario TEXT
      )
    ''');
  }

  // Crear un nuevo reporte
  static Future<int> createReport({
    required String titulo,
    required String descripcion,
    required String foto,
    required double latitud,
    required double longitud,
    String? usuario,
  }) async {
    final db = await database;

    final Map<String, dynamic> report = {
      'titulo': titulo,
      'descripcion': descripcion,
      'foto': foto,
      'latitud': latitud,
      'longitud': longitud,
      'fecha_creacion': DateTime.now().toIso8601String(),
      'usuario': usuario ?? 'Usuario Local',
    };

    return await db.insert(_tableReports, report);
  }

  // Obtener todos los reportes
  static Future<List<Map<String, dynamic>>> getAllReports() async {
    final db = await database;
    return await db.query(_tableReports, orderBy: 'fecha_creacion DESC');
  }

  // Obtener reportes por usuario
  static Future<List<Map<String, dynamic>>> getReportsByUser(
    String usuario,
  ) async {
    final db = await database;
    return await db.query(
      _tableReports,
      where: 'usuario = ?',
      whereArgs: [usuario],
      orderBy: 'fecha_creacion DESC',
    );
  }

  // Obtener un reporte por ID
  static Future<Map<String, dynamic>?> getReportById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      _tableReports,
      where: 'id = ?',
      whereArgs: [id],
    );

    return results.isNotEmpty ? results.first : null;
  }

  // Actualizar un reporte
  static Future<int> updateReport(int id, Map<String, dynamic> report) async {
    final db = await database;
    return await db.update(
      _tableReports,
      report,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar un reporte
  static Future<int> deleteReport(int id) async {
    final db = await database;
    return await db.delete(_tableReports, where: 'id = ?', whereArgs: [id]);
  }

  // Limpiar todas las tablas (para testing)
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_tableReports);
  }

  // Cerrar la base de datos
  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
