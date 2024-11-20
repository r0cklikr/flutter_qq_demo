import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'DBHelper.dart';
import 'model/entity/News.dart';
import 'NewsDetailPage.dart';

class NewsList extends StatefulWidget {
  const NewsList({super.key});

  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  List<News> _newsList = [];
  bool _isLoading = true;
  var logger = Logger();

  Future<List<News>> fetchNews() async {
    final response = await http.get(
      Uri.parse('https://apis.tianapi.com/generalnews/index?key=1630664ff95a87a28a6b2ff27dd4f565&rand=1&num=5'),
      //Uri.parse('https://apis.tianapi.com/caijing/index?key=1630664ff95a87a28a6b2ff27dd4f565&num=5&rand=1'),
    );

    if (response.statusCode == 200) {
      logger.i("获取新闻信息成功");
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> newsList = data['result']['newslist'];
      return newsList.map((news) => News.fromJson(news)).toList();
    } else {
      throw Exception('获取新闻失败');
    }
  }
  Future<List<News>> fetchNewsWithValidEntries() async {
    final dbHelper = DBHelper();
    List<News> newsList = [];
    try {
      // 从网络获取新闻
      newsList = await fetchNewsPre();
      // 保存到本地数据库
      for (var news in newsList) {
        await dbHelper.insertNews(news);
      }
      logger.i("当前有${dbHelper.printAllRecords("news")}条");
    }  on SocketException catch (e) {
      // 专门捕获无网络时的异常
      logger.e("网络连接失败: 无法访问网络，原因: ${e.message}");
      // 从数据库加载新闻
      newsList = await dbHelper.getRandomNews(5);
    }
    return newsList;
  }
  Future<List<News>> fetchNewsPre() async {
    final response = await http.get(
      Uri.parse('https://apis.tianapi.com/generalnews/index?key=1630664ff95a87a28a6b2ff27dd4f565&rand=1&num=5'),
      //
    //   Uri.parse('https://apis.tianapi.com/caijing/index?key=1630664ff95a87a28a6b2ff27dd4f565&num=5&rand=1'),
     // Uri.parse('https://apis.tianapi.com/internet/index?key=1630664ff95a87a28a6b2ff27dd4f565&num=5&rand=1'),
    );

    if (response.statusCode == 200) {
      logger.i("获取新闻信息成功");
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> newsList = data['result']['newslist'];
      List<News> validNewsList = [];
      for (var newsJson in newsList) {
        News news = News.fromJson(newsJson);
        news.url = _fixUrl(news.url);
        //if (await _isValidUrl(news.url)) {
        if (true) {
          validNewsList.add(news);
        } else {
          logger.w("无效新闻链接：${news.title} ${news.url}");
        }
      }
      return validNewsList;
    } else {
      throw Exception('获取新闻失败');
    }
  }
  Future<bool> _isValidUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      logger.e("URL 检查失败: $url");
      return false;
    }
  }
  // 刷新新闻列表
  Future<void> _onRefresh() async {
    List<News> newNews = await fetchNewsWithValidEntries();
    for (int i = 0; i < newNews.length; i++) {

      newNews[i].picUrl = _fixUrl(newNews[i].picUrl);
      newNews[i].url = _fixUrl(newNews[i].url);
      News news=newNews[i];
      print(news.title+" "+news.url+"图片:"+news.picUrl);
    }
    setState(() {
       _newsList.insertAll(0, newNews);
     // _newsList = newNews;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchNewsWithValidEntries().then((newNews) {
      for (int i = 0; i < newNews.length; i++) {

        newNews[i].picUrl = _fixUrl(newNews[i].picUrl);
        newNews[i].url = _fixUrl(newNews[i].url);
        News news=newNews[i];
        print(news.title+" "+news.url+"图片:"+news.picUrl);
      }
      setState(() {
        _newsList = newNews;
        _isLoading = false;
      });
    });
  }

  //处理URL
  String _fixUrl(String url) {
    if (url.isEmpty) return url;

    if (url.startsWith('https') || url.startsWith('http')) {
      return url;
    } else {
      return 'https:' + url;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Colors.blue,
      backgroundColor: Colors.white,
      child: _isLoading
          ? Container(
        color: Colors.white,
        child: Center(child: CircularProgressIndicator()),
      )
          : ListView.builder(
          itemCount: _newsList.length,
          itemBuilder: (context, index) {
          News news = _newsList[index];
          return Container(
            color: Colors.white,
            child: InkWell(
              onTap: () {
                // 点击新闻后跳转到 NewsDetailPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetailPage(
                      url: news.url,
                      title: news.title,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (news.description.isNotEmpty)
                      Text(
                        news.description,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                        maxLines: 2,
                      ),
                    SizedBox(height: 8),

                      genMetImg(news.picUrl),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '来源: ${news.source}',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        Text(
                          '发布时间: ${news.ctime}',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),


                    if(index!=_newsList.length-1)
                      Divider(
                      color: Color.fromRGBO(241,241,241, 1),
                      height: 1,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget genMetImg(String picUrl) {
    if (picUrl == null || picUrl.isEmpty) {
      logger.e("图片url为空");
      return Icon(
        Icons.broken_image,
        size: 50,
        color: Colors.grey,
      );
    }
    return  CachedNetworkImage(
        imageUrl: picUrl,
        placeholder: (context, url) =>
            CircularProgressIndicator(),
          errorWidget: (context, url, error){
            logger.e("加载失败图片 URL: $url");
            return FutureBuilder<Uint8List?>(
              future: _getImageFromDatabase(picUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // 数据库加载时显示进度条
                } else if (snapshot.hasData && snapshot.data != null) {
                    logger.i("从数据库获取图片");
                  return Image.memory(snapshot.data!);  // 从数据库加载的图片
                } else {
                  return Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ); // 图片加载失败时显示默认图标
                }
              },
            );
          // return Icon(
          //   Icons.broken_image,
          //   size: 50,
          //   color: Colors.grey,
          // );

        },

        fit: BoxFit.fill,
      );

    // return CachedNetworkImage(
    //   imageUrl: picUrl,
    //   placeholder: (context, url) =>
    //       CircularProgressIndicator(),
    //     errorWidget: (context, url, error){
    //     // Icon(Icons.error),
    //       logger.e("加载失败图片 URL: $url");
    //
    //     return Icon(
    //       Icons.broken_image,
    //       size: 50,
    //       color: Colors.grey,
    //     );
    //
    //   },
    //
    //   fit: BoxFit.fill,
    // );
  }
  Future<Uint8List?> _getImageFromDatabase(String picUrl) async {
    final dbHelper = DBHelper();
    return await dbHelper.getImageDataFromDatabase(picUrl);
  }
}