import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/entity/User.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  var logger = Logger();

  bool _isUsernameValid = false;
  bool _isPasswordValid = false;
  bool _isCharacterTypesValid = false;

  void _validateUsername(String username) {
    setState(() {
      _isUsernameValid = username.isNotEmpty && username.length >= 6&& username.length <=13;
    });
  }

  void _validatePassword(String password) {
    setState(() {
      _isPasswordValid = password.length >= 8 && password.length <= 16;

      final hasDigits = password.contains(RegExp(r'\d'));
      final hasLetters = password.contains(RegExp(r'[a-zA-Z]'));
      final hasSymbols = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      _isCharacterTypesValid = (hasDigits && hasLetters) ||
          (hasDigits && hasSymbols) ||
          (hasLetters && hasSymbols);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(243, 242, 247, 1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const Text(
                  '注册账号',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24.0),
            // 昵称输入框

              _buildInputField(
                label: '昵称',
                hintText: '请输入昵称',
                controller: _nicknameController,
              ),
              Divider(
                color: Color.fromRGBO(238, 238, 238, 1),
                thickness: 1,
              ),

              // 用户名输入框
              _buildInputField(
                label: 'QQ号',
                hintText: '请输入QQ号',
                controller: _usernameController,
                onChanged: (value) => _validateUsername(value),
              ),
              Divider(
                color: Color.fromRGBO(238, 238, 238, 1),
                thickness: 1,
              ),
              // 密码输入框
              _buildInputField(
                label: '密码',
                hintText: '请设置密码',
                controller: _passwordController,
                onChanged: (value) => _validatePassword(value),
                obscureText: true,
              ),
              Divider(
                color: Color.fromRGBO(238, 238, 238, 1),
                thickness: 1,
              ),
              // 确认密码输入框
              _buildInputField(
                label: '确认密码',
                hintText: '请再次输入密码',
                controller: _confirmPasswordController,
                obscureText: true,
              ),
              Divider(
                color: Color.fromRGBO(238, 238, 238, 1),
                thickness: 1,
              ),
              // 密码要求提示
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequirementItem(
                      text: '密码由8-16位数字、字母或符号组成',
                      isChecked: _isPasswordValid,
                    ),
                    const SizedBox(height: 8.0),
                    _buildRequirementItem(
                      text: '至少含2种以上字符',
                      isChecked: _isCharacterTypesValid,
                    ),
                  ],
                ),
              ),
              // 注册按钮
              Padding(
                padding: const EdgeInsets.only(
                    top: 16, bottom: 5, left: 16, right: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isUsernameValid &&
                            _isPasswordValid &&
                            _isCharacterTypesValid)
                        ? () => _register()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_isUsernameValid &&
                              _isPasswordValid &&
                              _isCharacterTypesValid)
                          ? Colors.blue
                          : Colors.grey,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: const Text(
                      '注册',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    void Function(String)? onChanged,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          (label=="密码"?SizedBox(width: 47,):label=="QQ号"?SizedBox(width: 26,):label=='昵称'?SizedBox(width: 36,):SizedBox(width: 8,)),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem({required String text, required bool isChecked}) {
    return Row(
      children: [
        Icon(
          isChecked ? Icons.check_circle : Icons.check_circle_outline,
          color: isChecked ? Colors.blue : Colors.grey,
          size: 16,
        ),
        const SizedBox(width: 8.0),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Future<void> _register() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String nickname = _nicknameController.text;

    if (username.length < 6 || username.length > 13) {
      _showDialog('错误', '用户名需要在6-13个字符之间');
      return;
    }
    if (password != _confirmPasswordController.text) {
      _showDialog('错误', '两次输入的密码不一致');
      return;
    }
    if (nickname.isEmpty) {
      _showDialog('错误', '昵称不能为空');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    //TODO
    //await prefs.remove('users');
    String? usersJson = prefs.getString('users');
    List<dynamic> usersList = usersJson != null ? json.decode(usersJson) : [];

    if (usersList.any((user) => user['username'] == username)) {
      _showDialog('错误', '用户名已被注册');
      return;
    }

    usersList.add({
      'username': username,
      'password': password,
      'nickname': nickname,
    });
    prefs.setString('users', json.encode(usersList));
    logger.i('注册成功: $username (昵称: $nickname)');

    _showDialog('成功', '注册成功！', onConfirm: () {
      Navigator.pop(context);
    });
  }


  void _showDialog(String title, String content, {VoidCallback? onConfirm}) {
    showDialog(

      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
            ),
          ],
        );
      },
    );
  }
}
