import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/expense.dart';

/// Singleton wrapper around the SQLite database.
///
/// All public methods are async and return typed results — callers never
/// interact with raw [Map] objects or [Database] instances directly.
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'expense_tracker.db';
  static const int _dbVersion = 1;

  static const String _tableExpenses = 'expenses';

  Database? _db;

  // ── Initialisation ────────────────────────────────────────────────────────

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableExpenses (
        id         TEXT    PRIMARY KEY,
        title      TEXT    NOT NULL,
        amount     REAL    NOT NULL,
        categoryId TEXT    NOT NULL,
        date       TEXT    NOT NULL,
        note       TEXT
      )
    ''');
  }

  // Migrations go here as the schema evolves.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Insert a new [expense] row.  Throws if the id already exists.
  Future<void> insertExpense(Expense expense) async {
    final db = await database;
    await db.insert(
      _tableExpenses,
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  /// Return all expenses ordered by [date] descending (newest first).
  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final rows = await db.query(
      _tableExpenses,
      orderBy: 'date DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  /// Return expenses whose [date] falls within [from] (inclusive) and [to]
  /// (inclusive).
  Future<List<Expense>> getExpensesByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final db = await database;
    final rows = await db.query(
      _tableExpenses,
      where: 'date >= ? AND date <= ?',
      whereArgs: [from.toIso8601String(), to.toIso8601String()],
      orderBy: 'date DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  /// Return expenses belonging to [categoryId].
  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    final db = await database;
    final rows = await db.query(
      _tableExpenses,
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  /// Fetch a single expense by [id], or null if not found.
  Future<Expense?> getExpenseById(String id) async {
    final db = await database;
    final rows = await db.query(
      _tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Expense.fromMap(rows.first);
  }

  /// Update an existing expense.  Returns the number of rows affected.
  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return db.update(
      _tableExpenses,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  /// Delete an expense by [id].  Returns the number of rows deleted.
  Future<int> deleteExpense(String id) async {
    final db = await database;
    return db.delete(
      _tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Sum of all expense amounts (useful for budget checks).
  Future<double> getTotalAmount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $_tableExpenses',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Aggregate totals grouped by category for the current month.
  Future<Map<String, double>> getCategoryTotalsForMonth(
    int year,
    int month,
  ) async {
    final from = DateTime(year, month);
    final to = DateTime(year, month + 1).subtract(const Duration(microseconds: 1));

    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT categoryId, SUM(amount) as total
      FROM $_tableExpenses
      WHERE date >= ? AND date <= ?
      GROUP BY categoryId
      ''',
      [from.toIso8601String(), to.toIso8601String()],
    );

    return {
      for (final row in rows)
        row['categoryId'] as String: (row['total'] as num).toDouble(),
    };
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
