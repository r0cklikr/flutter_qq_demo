import 'package:flutter/material.dart';
import 'ChangePasswordPage.dart';
import 'FavoritePage.dart';
import 'model/entity/User.dart';

class UserProfilePage extends StatelessWidget {
  final User user;

  UserProfilePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 242, 247),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 242, 247),
        leading: IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.black),
          onPressed: () {
            print('打卡成功');
          },
        ),
        elevation: 0,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // 检测从右向左滑动
          if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
            Navigator.pop(context); // 返回上一个页面
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前登录用户头像和名字
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(user.getImageUrl()), // 用户头像
                  ),
                  const SizedBox(width: 16), // 间距
                  Text(
                    user.getUserName(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // 用户名样式
                  ),
                ],
              ),
            ),
            // 列表
            Expanded(child: getList(context)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        color: const Color.fromARGB(255, 243, 242, 247),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black), // 设置图标按钮
                  onPressed: () {},
                ),
                const Text('设置', style: TextStyle(fontSize: 12, color: Colors.black)), // 按钮下方描述
              ],
            ),
            const SizedBox(width: 15),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.nightlight_round, color: Colors.black), // 夜间模式图标按钮
                  onPressed: () {},
                ),
                const Text('夜间', style: TextStyle(fontSize: 12, color: Colors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getList(BuildContext context) {
    return Center(
      child: Container(
        width: 380,
        padding: const EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('超级QQ秀'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {
                print('跳转到超级QQ秀');
              },
            ),
            ListTile(
              leading: const Icon(Icons.live_tv),
              title: const Text('直播'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.card_membership),
              title: const Text('SVIP'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {},
            ),ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('修改密码'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {
                // 跳转到修改密码页面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordPage(user: user), // 修改密码页面
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('我的QQ钱包'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.photo_album),
              title: const Text('我的相册'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('我的收藏'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {
                // 点击跳转到我的收藏页面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('我的文件'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('亲密空间'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.games),
              title: const Text('精品小游戏'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text('小金库'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.face),
              title: const Text('装扮'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
