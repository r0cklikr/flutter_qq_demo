import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:demohello/DBHelper.dart'; // 确保 DBHelper 已经实现
import 'package:demohello/model/entity/News.dart'; // 引入 News 类

class DbTestPage extends StatefulWidget {
  @override
  _DbTestPageState createState() => _DbTestPageState();
}

class _DbTestPageState extends State<DbTestPage> {
  // 这个变量用于保存查询到的新闻列表
  List<News> newsList = [];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  // 从数据库中获取新闻
  void _fetchNews() async {
    final dbHelper = DBHelper();
    final news = await dbHelper.getNewsByUrl('https://example.com'); // 获取所有新闻
    setState(() {

      if(news!=null)
      newsList = [news]; // 更新 UI
      else newsList=[];
    });
  }

  // 插入新闻
  void _insertNews() async {
    final dbHelper = DBHelper();
    final news = News(
      id: '31',
      title: '测试新闻',
      description: '这是测试新闻描述',
      url: 'https://example.com',
      picUrl: 'https://example.com/pic.jpg',
      source: '新闻源',
      ctime: '2024-11-22T10:00:00',
    );
    await dbHelper.insertNews(news); // 插入新闻
    _fetchNews(); // 插入后重新获取新闻
  }

  // 更新新闻
  void _updateNews() async {
    final dbHelper = DBHelper();
    final updatedNews = News(
      id: '1',
      title: '更新后的测试新闻',
      description: '这是更新后的测试新闻描述',
      url: 'https://example.com',
      picUrl: 'https://example.com/pic.jpg',
      source: '更新后的新闻源',
      ctime: '2024-11-22T10:00:00',
    );
    await dbHelper.updateNewsByUrl(updatedNews); // 更新新闻
    _fetchNews(); // 更新后重新获取新闻
  }

  // 删除新闻
  void _deleteNews() async {
    final dbHelper = DBHelper();
    await dbHelper.deleteNewsByUrl('https://example.com'); // 删除指定URL的新闻
    _fetchNews(); // 删除后重新获取新闻
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DB 操作示例'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _insertNews,
            child: Text('插入新闻'),
          ),
          ElevatedButton(
            onPressed: _updateNews,
            child: Text('更新新闻'),
          ),
          ElevatedButton(
            onPressed: _deleteNews,
            child: Text('删除新闻'),
          ),
          Expanded(
            child: newsList.length==0?Container():ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final news = newsList[index];
                return ListTile(
                  title: Text(news.title),
                  subtitle: Text(news.description),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter DB Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DbTestPage(), // 直接设置为 DbTestPage 页面
    );
  }
}