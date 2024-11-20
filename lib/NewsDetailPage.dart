import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsDetailPage extends StatefulWidget {
  final String url;
  final String title;

  NewsDetailPage({required this.url, required this.title});

  @override
  _NewsDetailPageState createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  late final WebViewController _controller;
  double _progress = 0.0;
  bool _showProgressIndicator = true; // 是否显示加载条
  bool _isFavorited = false; // 当前新闻是否已经收藏

  @override
  void initState() {
    super.initState();
    // 初始化 WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
              _showProgressIndicator = progress < 100; // 加载完毕后隐藏进度条
            });
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    // 检查当前新闻是否已经收藏
    _checkIfFavorited();
  }

  // 检查新闻是否已被收藏
  Future<void> _checkIfFavorited() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];

    String newsData = jsonEncode({
      'url': widget.url,
      'title': widget.title,
    });

    // 如果收藏列表中包含该新闻，更新状态
    if (favorites.contains(newsData)) {
      setState(() {
        _isFavorited = true;
      });
    }
  }

  // 收藏/取消收藏功能，将新闻的url和title保存或删除到本地缓存中
  Future<void> _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];

    String newsData = jsonEncode({
      'url': widget.url,
      'title': widget.title,
    });

    if (_isFavorited) {
      favorites.remove(newsData); // 从收藏列表中移除
      await prefs.setStringList('favorites', favorites);

      setState(() {
        _isFavorited = false; // 更新收藏状态
      });


    } else {
      favorites.insert(0,newsData); // 添加到收藏列表
      await prefs.setStringList('favorites', favorites);

      setState(() {
        _isFavorited = true; // 更新收藏状态
      });


    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: const Color.fromRGBO(240, 244, 255, 1),
        title: Text(widget.title),
        actions: [
          // 收藏按钮，点击后改变颜色
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : Colors.grey,
            ),
            onPressed: _toggleFavorite, // 切换收藏状态
          ),
        ],
      ),
      body: Column(
        children: [
          // 显示进度条
          _showProgressIndicator
              ? LinearProgressIndicator(
            minHeight: 2,
            value: _progress, // 设置进度
            backgroundColor: Colors.grey[300]!,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          )
              : const SizedBox(), // 加载完成后隐藏进度条
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}
