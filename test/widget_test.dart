import 'package:flutter_test/flutter_test.dart';
import 'package:demohello/DBHelper.dart';
import 'package:demohello/model/entity/News.dart'; // 引入 News 类

void main() {
  // 插入新闻
  test('插入新闻到数据库', () async {

    final dbHelper = DBHelper();

    // 创建一个测试新闻对象
    final news = News(
      id: '1',
      title: '测试新闻',
      description: '这是测试新闻描述',
      url: 'https://example.com',
      picUrl: 'https://example.com/pic.jpg',
      source: '新闻源',
      ctime: '2024-11-22T10:00:00',
    );

    // 插入新闻
    await dbHelper.insertNews(news);

  });

  // 查询所有新闻记录
  test('查询所有新闻记录', () async {
    final dbHelper = DBHelper();

    dbHelper.printAllRecords("news");


  });

  // 更新新闻
  test('更新新闻', () async {
    final dbHelper = DBHelper();

    // 创建一个新闻对象
    final news = News(
      id: '1',
      title: '测试新闻',
      description: '这是测试新闻描述',
      url: 'https://example.com',
      picUrl: 'https://example.com/pic.jpg',
      source: '新闻源',
      ctime: '2024-11-22T10:00:00',
    );

    // 插入新闻
    await dbHelper.insertNews(news);

    // 更新新闻内容
    final updatedNews = News(
      id: '1',
      title: '更新后的测试新闻',
      description: '这是更新后的测试新闻描述',
      url: 'https://example.com',
      picUrl: 'https://example.com/pic.jpg',
      source: '更新后的新闻源',
      ctime: '2024-11-22T10:00:00',
    );

    // 更新新闻
    await dbHelper.updateNewsByUrl(updatedNews);

    dbHelper.printAllRecords("news");
  });

  // 删除新闻
  test('删除新闻', () async {
    final dbHelper = DBHelper();

    // 创建一个新闻对象
    final news = News(
      id: '1',
      title: '测试新闻',
      description: '这是测试新闻描述',
      url: 'https://example.com',
      picUrl: 'https://example.com/pic.jpg',
      source: '新闻源',
      ctime: '2024-11-22T10:00:00',
    );

    // 插入新闻
    await dbHelper.insertNews(news);

    // 删除新闻
    await dbHelper.deleteNewsByUrl(news.url);
    dbHelper.printAllRecords("news");

  });
}
