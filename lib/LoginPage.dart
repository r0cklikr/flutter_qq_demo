import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MyMainPage.dart';
import 'RegisterPage.dart';
import 'model/entity/User.dart';
class QQ extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QQ登录',
      theme: ThemeData(primarySwatch: Colors.blue),

      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    _loadCredentials();  // 页面加载时读取缓存
  }
  final TextEditingController qqController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isCheckedAgreement = false;  // 单独管理“同意协议”复选框的状态
  bool _isCheckedRemember = false;   // 单独管理“记住密码”复选框的状态
  bool _isPasswordVisible=false;
  var logger = Logger();
  // 从缓存加载账号密码
  _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isRem = prefs.getBool('isRem') ?? false; // 获取是否勾选记住密码
    if (isRem) {

      String? savedAccount = prefs.getString('rememAccount');
      String? savedPassword = prefs.getString('rememPasswd');
      logger.i("记住密码,账号:${savedAccount}密码:${savedPassword}");
      if (savedAccount != null && savedPassword != null) {
        qqController.text = savedAccount;
        passwordController.text = savedPassword;
        setState(() {
          _isCheckedRemember = true;  // 正确更新复选框的状态
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 120),
              Container(
                height: 60,
                width: 120,
                child: Image.asset(
                  'assets/01_qq_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 50),
              createAccountTextField()
              ,
              SizedBox(height: 20),
              // 密码输入框
              createPasswdTextField(),
              SizedBox(height: 10),
              createCheckNav(),
              // 登录按钮
              SizedBox(height: 50,),
              createLoginButton(),
              SizedBox(height: 220,),
              createBottomNav()
            ],
          ),
        ),
      ),
    );
  }

  Widget createAccountTextField(){

    return Container(
      alignment: Alignment.center,
      height: 70,
      width: 340,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(242, 243, 247, 0.8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: qqController,
        style: const TextStyle(fontSize: 18, color: Colors.black),
        decoration: const InputDecoration(
          // border:  OutlineInputBorder(),
            border: InputBorder.none,
            hintText: '输入 QQ 号',
            hintStyle:  TextStyle(color: Colors.grey),
            contentPadding: EdgeInsets.symmetric(horizontal: 45)
        ),
        textAlign: TextAlign.center,
      ),
    );

  }
  Widget createPasswdTextField(){
    return Container(
      alignment: Alignment.center,
      height: 70,
      width: 340,
      decoration: BoxDecoration(
        color: Color.fromRGBO(242, 243, 247, 0.8),
        borderRadius: BorderRadius.circular(30),
      ),
        child: TextField(
          controller: passwordController,
          obscureText: !_isPasswordVisible,
          style: TextStyle(fontSize: 18, color: Colors.black),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 45,vertical: 10),
            suffixIcon: IconButton(

              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: InputBorder.none,
            hintText: '输入 QQ 密码',
            hintStyle: TextStyle(color: Colors.grey),

          ),
          textAlign: TextAlign.center,
        ),
    );
  }
  Widget createCheckNav() {
    return Column(
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              activeColor: Colors.blue,
              checkColor: Colors.white,
              shape: CircleBorder(),
              value: _isCheckedAgreement,
              onChanged: (bool? value) {
                setState(() {
                  _isCheckedAgreement = value!;
                });
              },
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '我已阅读并同意',
                    style: TextStyle(color: Colors.black, fontSize: 13),
                  ),
                  TextSpan(
                    text: '服务协议',
                    style: TextStyle(color: Colors.blue, fontSize: 13),
                  ),
                  TextSpan(
                    text: '和',
                    style: TextStyle(color: Colors.black, fontSize: 13),
                  ),
                  TextSpan(
                    text: 'QQ隐私保护指引',
                    style: TextStyle(color: Colors.blue, fontSize: 13),
                  ),
                ],
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width:53,),
            Checkbox(
              activeColor: Colors.blue,
              checkColor: Colors.white,
              shape: CircleBorder(),
              value: _isCheckedRemember,
              onChanged: (bool? value) {
                setState(() {
                  _isCheckedRemember = value!;
                });
              },
            ),

            Text('记住密码',style: TextStyle(fontSize: 11),),
          ],
        ),
      ],
    );
  }

  Widget createLoginButton(){
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(25),
        backgroundColor: Colors.blue,
      ),
      child: Icon(
        Icons.arrow_forward,
        color: Colors.white,
        size: 40,
      ),
      onPressed: () async {
        String account = qqController.text;
        String passwd = passwordController.text;
        if(account.length<6||account.length>13){
          // 显示错误提示
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('账户位数应在6-13'),
                actions: <Widget>[
                  TextButton(
                    child: Text('确定'),
                    onPressed: () {
                      Navigator.of(context).pop(); // 关闭对话框
                    },
                  ),
                ],
              );
            },
          );
          qqController.text="";
          return;
        }
        if(passwd.isEmpty){
          // 显示错误提示
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('密码不能为空'),
                actions: <Widget>[
                  TextButton(
                    child: Text('确定'),
                    onPressed: () {
                      Navigator.of(context).pop(); // 关闭对话框
                    },
                  ),
                ],
              );
            },
          );
          passwordController.text="";
          return;
        }
        if(!_isCheckedAgreement){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('没有同意协议'),
                actions: <Widget>[
                  TextButton(
                    child: Text('确定'),
                    onPressed: () {
                      Navigator.of(context).pop(); // 关闭对话框
                    },
                  ),
                ],
              );
            },
          );
          return;
        }
        //校验账户密码

      bool isValid = await _validateCredentials(account, passwd);

      if(isValid){
        logger.i("登陆成功 ${account} ${passwd}");
        // 保存账号密码到缓存
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (_isCheckedRemember) {
          prefs.setBool('isRem', true);
          prefs.setString('rememAccount', account);
          prefs.setString('rememPasswd', passwd);
        } else {
          prefs.setBool('isRem', false);
          prefs.remove('rememAccount');
          prefs.remove('rememPasswd');
        }
        // 从缓存中获取用户列表
        String? usersJson = prefs.getString('users');
        if (usersJson == null || usersJson.isEmpty) {
          return null; // 如果没有用户数据，返回 null
        }

        List<dynamic> usersList = json.decode(usersJson);

        // 根据账号和密码查找用户
        var matchedUser = usersList.firstWhere(
              (user) => user['username'] == account && user['password'] == passwd,
          orElse: () => null,
        );
        logger.i("缓存中获取到昵称:${matchedUser['nickname']}");
        User user=getLoginUser(account,passwd);
        user.setUserName(matchedUser['nickname']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyMainPage(user: user)),
        );
      }else{
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('密码错误或账户不存在'),
              actions: <Widget>[
                TextButton(
                  child: Text('确定'),
                  onPressed: () {
                    Navigator.of(context).pop(); // 关闭对话框
                  },
                ),
              ],
            );
          },
        );
      }
      },

    );
  }
  // 验证输入的账号密码
  _validateCredentials(String account, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.clear();

    // 获取保存的用户列表
    String? usersJson = prefs.getString('users');
    if (usersJson == null) {
      // 如果没有保存的用户信息，返回验证失败
      return false;
    }

    List<dynamic> usersList = json.decode(usersJson);
    print("获取到的用户列表: $usersList");
    // 遍历用户列表，检查是否存在匹配的账号密码
    for (var user in usersList) {
      if (user['username'] == account && user['password'] == password) {
        return true; // 账号密码匹配，验证成功
      }
    }

    return false; // 未找到匹配的账号密码，验证失败
  }
  Widget createBottomNav()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,  // 水平居中
      children: [
        TextButton(
          onPressed: () {
            //手机号登录
          },
          child: Text('手机号登录',style: TextStyle(color: Colors.black),),
        ),
        SizedBox(
          height: 10,
          child: VerticalDivider(
            width: 20,
            thickness: 2,
            color: Color.fromRGBO(237, 240, 243, 1),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage()),
            );
          },
          child: Text('新用户注册',style: TextStyle(color: Colors.black),),
        ),
        SizedBox(
          height: 10,
          child: VerticalDivider(
            width: 20,
            thickness: 2,
            color: Color.fromRGBO(237, 240, 243, 1),
          ),
        ),
        TextButton(
          onPressed: () {
            //操作
          },
          child: Text('更多选项',style: TextStyle(color: Colors.black),),
        ),
      ],
    );
  }
  User getLoginUser(String account,String passwd){
    User user= User();
    user.setAccount(account);
    user.setPasswd(passwd);
    return user;
  }
  _saveCredentials(String account, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 获取已保存的用户列表（如果没有则返回空列表）
    String? usersJson = prefs.getString('users');
    List<dynamic> usersList = usersJson != null ? json.decode(usersJson) : [];

    // 将新的账号密码添加到列表中
    Map<String, String> newUser = {'account': account, 'password': password};
    usersList.add(newUser);

    // 将更新后的用户列表存储为 JSON 字符串
    String updatedUsersJson = json.encode(usersList);
    prefs.setString('users', updatedUsersJson);
  }



}
void main() {
  runApp(QQ());
}
