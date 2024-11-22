import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'model/entity/News.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {

    final dbPath = await getDatabasesPath();
    final path = dbPath+ 'news_database.db';
   // await deleteDatabase(path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(''' 
          CREATE TABLE news (
            id TEXT PRIMARY KEY ,
            title TEXT,
            description TEXT,
            url TEXT  UNIQUE,
            picUrl TEXT,
            source TEXT,
            ctime TEXT,
            picData BLOB  -- 添加图片二进制数据字段
          )
        ''');
      },

    );
  }

  Future<void> insertNews(News news) async {
    final db = await database;
    // 获取图片数据
    Uint8List? picData = await _fetchImageData(news.picUrl);

    // 如果图片数据为空，设置为null或空字符串
    news.picData = picData ?? null;

    await db.insert(
      'news',
      news.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<Uint8List?> _fetchImageData(String picUrl) async {
    try {
      final response = await http.get(Uri.parse(picUrl));
      if (response.statusCode == 200) {
        // 图片下载成功，返回二进制数据
        return response.bodyBytes;
      } else {
        // 如果图片下载失败，返回null
        return null;
      }
    } catch (e) {
      // 如果发生错误，返回null
      return null;
    }
  }

  Future<List<News>> getRandomNews(int count) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM news ORDER BY RANDOM() LIMIT ?',
      [count],
    );
    return maps.map((map) => News.fromMap(map)).toList();
  }

  Future<List<News>> getNews() async {
    final db = await database;
    final maps = await db.query('news');
    return maps.map((map) => News.fromMap(map)).toList();
  }

  // 获取图片二进制数据
  Future<Uint8List?> getImageDataFromDatabase(String picUrl) async {
    //printAllRecords("news");
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'news',
      columns: ['picData'],
      where: 'picUrl = ?',
      whereArgs: [picUrl],
    );
    if (result.isNotEmpty) {
      return result.first['picData'] as Uint8List;
    }
    return null;
  }


  Future<void> printAllRecords(String tableName) async {
    final db = await database;
    final List<Map<String, dynamic>> records = await db.query(tableName);

    if (records.isEmpty) {
      print("表 $tableName 中没有记录");
    } else {
      for (var record in records) {
        print(record);
      }
    }
  }
// 更新指定URL的新闻记录
  Future<void> updateNewsByUrl(News updatedNews) async {
    final db = await database;
    // 使用url作为条件更新新闻记录
    await db.update(
      'news',
      updatedNews.toMap(),
      where: 'url = ?',
      whereArgs: [updatedNews.url],
    );
  }

  // 删除指定URL的新闻记录
  Future<void> deleteNewsByUrl(String url) async {
    final db = await database;
    // 使用url作为条件删除新闻记录
    await db.delete(
      'news',
      where: 'url = ?',
      whereArgs: [url],
    );
  }
  Future<News?> getNewsByUrl(String url) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'news',
      where: 'url = ?',
      whereArgs: [url],
    );
    if (result.isNotEmpty) {
      return News.fromMap(result.first);
    }
    return null; // 如果没有找到对应的新闻，返回 null
  }
}
