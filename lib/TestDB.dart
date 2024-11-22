

import 'package:sqflite/sqflite.dart';

Database? _database;

// 获取数据库实例
Future<Database> get database async {
  if (_database != null) return _database!;
  // 如果数据库为空，先初始化数据库
  _database = await _initDatabase();
  return _database!;
}

// 初始化数据库
Future<Database> _initDatabase() async {
  final dbPath = await getDatabasesPath();
  String path = dbPath+'students.db';
  return await openDatabase(path, version: 1, onCreate: (db, version) {
    // 创建学生表
    db.execute('''
        CREATE TABLE students(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          age INTEGER,
          grade TEXT
        )
      ''');
  });
}

// 插入学生信息
Future<int> insertStudent(Map<String, dynamic> student) async {
  final db = await database;
  return await db.insert('students', student);
}

// 获取所有学生信息
Future<List<Map<String, dynamic>>> getAllStudents() async {
  final db = await database;
  return await db.query('students');
}

// 更新学生信息
Future<int> updateStudent(int id, Map<String, dynamic> student) async {
  final db = await database;
  return await db.update(
    'students',
    student,
    where: 'id = ?',
    whereArgs: [id],
  );
}

// 删除学生信息
Future<int> deleteStudent(int id) async {
  final db = await database;
  return await db.delete(
    'students',
    where: 'id = ?',
    whereArgs: [id],
  );
}
Future<void> main() async {
// 插入学生信息
  print("插入学生信息...");
  int id1 = await insertStudent({
    'name': '张三',
    'age': 20,
    'grade': '大一',
  });
  print("插入成功，学生ID: $id1");

  int id2 = await insertStudent({
    'name': '李四',
    'age': 22,
    'grade': '大二',
  });
  print("插入成功，学生ID: $id2");

  // 查询所有学生信息
  print("\n查询所有学生信息...");
  List<Map<String, dynamic>> students = await getAllStudents();
  students.forEach((student) {
    print("ID: ${student['id']}, 姓名: ${student['name']}, 年龄: ${student['age']}, 年级: ${student['grade']}");
  });

  // 更新学生信息
  print("\n更新学生信息...");
  int updatedCount = await updateStudent(id1, {
    'name': '张三丰',
    'age': 21,
    'grade': '大二',
  });
  print("更新完成，影响的行数: $updatedCount");

  // 查询更新后的学生信息
  print("\n查询更新后的学生信息...");
  students = await getAllStudents();
  students.forEach((student) {
    print("ID: ${student['id']}, 姓名: ${student['name']}, 年龄: ${student['age']}, 年级: ${student['grade']}");
  });

  // 删除学生信息
  print("\n删除学生信息...");
  int deletedCount = await deleteStudent(id2);
  print("删除完成，影响的行数: $deletedCount");

  // 查询删除后的学生信息
  print("\n查询删除后的学生信息...");
  students = await getAllStudents();
  students.forEach((student) {
    print("ID: ${student['id']}, 姓名: ${student['name']}, 年龄: ${student['age']}, 年级: ${student['grade']}");
  });
}