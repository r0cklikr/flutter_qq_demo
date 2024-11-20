import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NewsDetailPage.dart';  // 导入新闻详情页面

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, String>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // 从本地缓存加载收藏的新闻
  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];

    List<Map<String, String>> favoriteNews = favorites.map((item) {
      return Map<String, String>.from(jsonDecode(item));
    }).toList();

    setState(() {
      _favorites = favoriteNews;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(240, 244, 255, 1),
        title: const Text("我的收藏"),
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites, // 下拉刷新时调用的函数
        color: Colors.blue,
        backgroundColor: Colors.white,
        child: _favorites.isEmpty
            ? const Center(child: Text("您没有收藏任何新闻"))
            : ListView.builder(
          itemCount: _favorites.length * 2 - 1, // 因为要加分割线，所以总项数为原始项数 * 2 - 1
          itemBuilder: (context, index) {
            if (index.isOdd) {
              return Divider(
                color: Color.fromRGBO(241,241,241, 1),
                height: 1,
                thickness: 1,
                indent: 10,
                endIndent: 10,
              );
            }
            int realIndex = index ~/ 2; // 计算实际的新闻索引
            var news = _favorites[realIndex];
            return ListTile(
              title: Text(news['title'] ?? '无标题'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {
                // 点击跳转到新闻详情页面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetailPage(
                      url: news['url']!,
                      title: news['title']!,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
