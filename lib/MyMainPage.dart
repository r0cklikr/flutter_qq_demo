import 'dart:io';
import 'dart:math';


import 'package:demohello/NewsList.dart';
import 'package:demohello/WeatherPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/bg/weather_bg.dart';
import 'package:flutter_weather_bg_null_safety/utils/weather_type.dart';

import 'ChatPageVis.dart';
import 'UserProfilePage.dart';
import 'model/entity/Message.dart';
import 'model/entity/User.dart';

class MyMainPage extends StatelessWidget {
  final User user;
  MyMainPage({required this.user});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(user: user,),
      debugShowCheckedModeBanner: false,
    );
  }

}

class HomeScreen extends StatefulWidget {
  final User user;
  HomeScreen({required this.user});
  @override
  _HomeScreenState createState() => _HomeScreenState(user: user);
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final User user;
  _HomeScreenState({required this.user});
  // 定义页面列表
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    // 在 initState 中初始化 _pages 列表
    _pages = [
      // 调用 genMsgList() 方法生成消息列表
      genMsgList(),
      // 其他页面
      WeatherPage(),
      genWea(),
      NewsList(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: const Color.fromRGBO(240, 244, 255, 1),
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                // 点击头像时，跳转到用户个人界面并传递当前登录用户信息
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(user: getLoginUser()),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(getLoginUser().getImageUrl()),
              ),
            ),
            const SizedBox(width: 8),
            Text(getLoginUser().getUserName()),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 35,
            onPressed: () {
              showMenu(
                color: Colors.white,
                context: context,
                position: const RelativeRect.fromLTRB(100, 90, 0, 0),
                items: [
                  const PopupMenuItem(child: Text("添加好友")),
                  const PopupMenuItem(child: Text("扫一扫")),
                ],
              );
            },
          ),

        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color.fromRGBO(238, 237, 242, 1),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.message), label: '消息'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: '小世界'),
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: '联系人'),
          BottomNavigationBarItem(icon: Icon(Icons.dynamic_feed), label: '动态'),
        ],
      ),
    );
  }

  Widget genMsgList(){
    
    List<Message> messages=[];
    List<String> urls=["https://md-bucket-1318593463.cos.ap-chengdu.myqcloud.com/img/c17d85a851e9444d7cf11a2fe491cdcb.jpg",
                    "https://md-bucket-1318593463.cos.ap-chengdu.myqcloud.com/img/5100fa60edfdd7b0c5ff0ceaf4d2fb9e.jpg",
                    "https://md-bucket-1318593463.cos.ap-chengdu.myqcloud.com/img/afb32b1a78bcd466c4072a95cc785d18.jpg",
                    "https://md-bucket-1318593463.cos.ap-chengdu.myqcloud.com/img/643ff6b06c3529c6e2eef79737df9783.jpg",
                    "https://md-bucket-1318593463.cos.ap-chengdu.myqcloud.com/img/3d3861e78043af6c37381b5df2d36e55.jpg",
                    "https://md-bucket-1318593463.cos.ap-chengdu.myqcloud.com/img/734304818ebb74592e929acd0ab3f403.jpg",
                    "https://md-bucket-1318593463.cos.ap-chengdu.myqcloud.com/img/b6a2401af50fc7aeedac8a2c31b874c5.jpg",
                    "https://md-bucket-1318593463.cos.ap-chengdu.myqcloud.com/img/097876f3c04356268c062fd3b5c03304.jpg"];
    Random random=Random();
    for(int i=0;i<30;i++){
        messages.add(Message(userName: '好友 ${i}', imageUrl: urls[random.nextInt(urls.length)], lastMessage: '2024年美国大选进入最后冲刺阶段，多州开启提前投票。民主党候选人、副总统卡玛拉·哈里斯和共和党候选人、前总统唐纳德·特朗普目前的民调结果不分上下，这意味着早期投票结果将受到两党的密切关注。11月5日是美国大选投票日，但美国多州允许选民提前投票。美国佛罗里达大学选举实验室的数据显示，截至美东时间25日早间11时，全美已有超过3300万名选民就总统大选进行了提前投票。其中，大约有超过1500万人提前到投票站投票，超过1700万人提前邮寄选票，首批邮寄选票9月11日'));
    }
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(messages[index].imageUrl),
            ),
            title: Text(messages[index].userName),
            subtitle: Text(messages[index].lastMessage,style: const TextStyle(color: Colors.grey),maxLines: 1,),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      message: messages[index],
                      user: getLoginUser(), // 传递登录的用户信息
                    ),
                  ),
                );
              },
          );
        },
      ),
    );
  }

  User getLoginUser(){
    return user;
  }

  Widget genWea() {
    return WeatherBg(
      weatherType: WeatherType.lightRainy,
      width: 10 ,// 填充整个宽度
      height: 10, // 填充整个高度
    );
  }

}


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;//跳过 SSL 证书验证
  }
}