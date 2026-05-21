import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/plan_model.dart';
import '../models/nested_task_model.dart';
import '../models/template_model.dart';
import '../models/template_task_model.dart';
import '../models/format_model.dart';
import '../models/format_field_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nest_plan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const integerNullable = 'INTEGER';

    await db.execute(
      'CREATE TABLE plans (id $idType, title $textType, date $textType, time $textNullable, endDate $textNullable, isRange $integerType, parentId $integerNullable)',
    );
    await db.execute(
      'CREATE TABLE nested_tasks (id $idType, planId $integerType, title $textType, detail $textNullable, time $textNullable, isCompleted $integerType, FOREIGN KEY (planId) REFERENCES plans (id) ON DELETE CASCADE)',
    );
    await db.execute('CREATE TABLE templates (id $idType, title $textType)');
    await db.execute(
      'CREATE TABLE template_tasks (id $idType, templateId $integerType, title $textType, detail $textNullable, time $textNullable, FOREIGN KEY (templateId) REFERENCES templates (id) ON DELETE CASCADE)',
    );
    await db.execute('CREATE TABLE formats (id $idType, title $textType)');
    await db.execute(
      'CREATE TABLE format_fields (id $idType, formatId $integerType, fieldName $textType, FOREIGN KEY (formatId) REFERENCES formats (id) ON DELETE CASCADE)',
    );

    await _insertDefaultFormats(db);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE plans ADD COLUMN time TEXT');
      await db.execute('ALTER TABLE nested_tasks ADD COLUMN time TEXT');
    }
    if (oldVersion < 3) {
      await db.execute(
        'CREATE TABLE templates (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL)',
      );
      await db.execute(
        'CREATE TABLE template_tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, templateId INTEGER NOT NULL, title TEXT NOT NULL, detail TEXT, time TEXT, FOREIGN KEY (templateId) REFERENCES templates (id) ON DELETE CASCADE)',
      );
    }
    if (oldVersion < 4) {
      await db.execute(
        'CREATE TABLE formats (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL)',
      );
      await db.execute(
        'CREATE TABLE format_fields (id INTEGER PRIMARY KEY AUTOINCREMENT, formatId INTEGER NOT NULL, fieldName TEXT NOT NULL, FOREIGN KEY (formatId) REFERENCES formats (id) ON DELETE CASCADE)',
      );
      await _insertDefaultFormats(db);
    }
  }

  Future<void> _insertDefaultFormats(Database db) async {
    int sporId = await db.insert('formats', {'title': 'Spor Antrenmanı'});
    await db.insert('format_fields', {
      'formatId': sporId,
      'fieldName': 'Hareket Adı',
    });
    await db.insert('format_fields', {'formatId': sporId, 'fieldName': 'Set'});
    await db.insert('format_fields', {
      'formatId': sporId,
      'fieldName': 'Tekrar',
    });
    await db.insert('format_fields', {
      'formatId': sporId,
      'fieldName': 'Ağırlık',
    });

    int diyetId = await db.insert('formats', {'title': 'Beslenme / Diyet'});
    await db.insert('format_fields', {
      'formatId': diyetId,
      'fieldName': 'Öğün (Örn: Kahvaltı)',
    });
    await db.insert('format_fields', {
      'formatId': diyetId,
      'fieldName': 'Yiyecekler',
    });
    await db.insert('format_fields', {
      'formatId': diyetId,
      'fieldName': 'Kalori',
    });
  }

  Future<int> insertPlan(PlanModel plan) async {
    final db = await instance.database;
    return await db.insert('plans', plan.toMap());
  }

  Future<List<PlanModel>> getMainPlans() async {
    final db = await instance.database;
    final result = await db.query(
      'plans',
      where: 'parentId IS NULL',
      orderBy: 'date ASC',
    );
    return result.map((json) => PlanModel.fromMap(json)).toList();
  }

  Future<List<PlanModel>> getPlansByDate(String date) async {
    final db = await instance.database;
    final result = await db.query(
      'plans',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.map((json) => PlanModel.fromMap(json)).toList();
  }

  Future<List<PlanModel>> getPlansByDateAndParent(
    String date,
    int parentId,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'plans',
      where: 'date = ? AND parentId = ?',
      whereArgs: [date, parentId],
      orderBy: 'time ASC',
    );
    return result.map((json) => PlanModel.fromMap(json)).toList();
  }

  Future<List<PlanModel>> getChildrenPlans(int parentId) async {
    final db = await instance.database;
    final result = await db.query(
      'plans',
      where: 'parentId = ?',
      whereArgs: [parentId],
    );
    return result.map((json) => PlanModel.fromMap(json)).toList();
  }

  Future<int> updatePlan(PlanModel plan) async {
    final db = await instance.database;
    return db.update(
      'plans',
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  Future<int> deletePlan(int id) async {
    final db = await instance.database;
    return await db.delete('plans', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertNestedTask(NestedTaskModel task) async {
    final db = await instance.database;
    return await db.insert('nested_tasks', task.toMap());
  }

  Future<List<NestedTaskModel>> getNestedTasks(int planId) async {
    final db = await instance.database;
    final result = await db.query(
      'nested_tasks',
      where: 'planId = ?',
      whereArgs: [planId],
    );
    return result.map((json) => NestedTaskModel.fromMap(json)).toList();
  }

  Future<int> updateNestedTask(NestedTaskModel task) async {
    final db = await instance.database;
    return db.update(
      'nested_tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> toggleTaskCompletion(int id, int currentStatus) async {
    final db = await instance.database;
    return await db.update(
      'nested_tasks',
      {'isCompleted': currentStatus == 1 ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNestedTask(int id) async {
    final db = await instance.database;
    return await db.delete('nested_tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertTemplate(TemplateModel template) async {
    final db = await instance.database;
    return await db.insert('templates', template.toMap());
  }

  Future<List<TemplateModel>> getTemplates() async {
    final db = await instance.database;
    final result = await db.query('templates', orderBy: 'id DESC');
    return result.map((json) => TemplateModel.fromMap(json)).toList();
  }

  Future<int> updateTemplate(TemplateModel template) async {
    final db = await instance.database;
    return db.update(
      'templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<int> deleteTemplate(int id) async {
    final db = await instance.database;
    return await db.delete('templates', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertTemplateTask(TemplateTaskModel task) async {
    final db = await instance.database;
    return await db.insert('template_tasks', task.toMap());
  }

  Future<List<TemplateTaskModel>> getTemplateTasks(int templateId) async {
    final db = await instance.database;
    final result = await db.query(
      'template_tasks',
      where: 'templateId = ?',
      whereArgs: [templateId],
    );
    return result.map((json) => TemplateTaskModel.fromMap(json)).toList();
  }

  Future<int> updateTemplateTask(TemplateTaskModel task) async {
    final db = await instance.database;
    return db.update(
      'template_tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTemplateTask(int id) async {
    final db = await instance.database;
    return await db.delete('template_tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertFormat(FormatModel format) async {
    final db = await instance.database;
    return await db.insert('formats', format.toMap());
  }

  Future<List<FormatModel>> getFormats() async {
    final db = await instance.database;
    final result = await db.query('formats', orderBy: 'id DESC');
    return result.map((json) => FormatModel.fromMap(json)).toList();
  }

  Future<int> deleteFormat(int id) async {
    final db = await instance.database;
    return await db.delete('formats', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertFormatField(FormatFieldModel field) async {
    final db = await instance.database;
    return await db.insert('format_fields', field.toMap());
  }

  Future<List<FormatFieldModel>> getFormatFields(int formatId) async {
    final db = await instance.database;
    final result = await db.query(
      'format_fields',
      where: 'formatId = ?',
      whereArgs: [formatId],
    );
    return result.map((json) => FormatFieldModel.fromMap(json)).toList();
  }

  Future<int> updateFormat(FormatModel format) async {
    final db = await instance.database;
    return db.update(
      'formats',
      format.toMap(),
      where: 'id = ?',
      whereArgs: [format.id],
    );
  }

  Future<void> deleteFormatFields(int formatId) async {
    final db = await instance.database;
    await db.delete(
      'format_fields',
      where: 'formatId = ?',
      whereArgs: [formatId],
    );
  }
}
