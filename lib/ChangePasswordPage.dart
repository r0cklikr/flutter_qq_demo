import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/entity/User.dart';

class ChangePasswordPage extends StatefulWidget {

  final User user;
  ChangePasswordPage({required this.user});
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState(user: user);
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  var logger = Logger();
  bool _isPasswordValid = false;
  bool _isCharacterTypesValid = false;
  User user; // 声明 user 变量
  _ChangePasswordPageState({required this.user});

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
                  '设置新密码',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24.0),
              // 新密码输入框
              _buildPasswordField(
                label: '新密码',
                hintText: '请设置密码',
                controller: _newPasswordController,
                onChanged: (value) => _validatePassword(value),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(
                  color: Color.fromRGBO(238, 238, 238, 1), // 分割线颜色：灰色
                  thickness: 1, // 分割线厚度
                  indent: 0, // 左侧缩进
                  endIndent: 0, // 右侧缩进
                ),
              ),
              // 确认新密码输入框
              _buildPasswordField(
                label: '确认密码',
                hintText: '请再次输入新密码',
                controller: _confirmPasswordController,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(
                  color: Color.fromRGBO(238, 238, 238, 1), // 分割线颜色：灰色
                  thickness: 1, // 分割线厚度
                  indent: 0, // 左侧缩进
                  endIndent: 0, // 右侧缩进
                ),
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
              // 确定按钮
              Padding(
                padding:
                const EdgeInsets.only(top: 16, bottom: 5, left: 16, right: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:  (_isPasswordValid && _isCharacterTypesValid) ? () => _changePassword() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_isPasswordValid && _isCharacterTypesValid)
                          ? Colors.blue // 可点击时为蓝色
                          : Colors.grey, // 不可点击时为灰色
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: const Text(
                      '确定',
                      style: TextStyle(fontSize: 16, color: Colors.white),

                    ),
                  ),
                ),
              ),
              // 安全提示
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 10),
                child: const Text(
                  '安全提示：新密码请勿与旧密码过于相似。',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          label == "新密码"
              ? const SizedBox(width: 36.0)
              : const SizedBox(width: 16.0),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                return TextField(
                  controller: controller,
                  onChanged: onChanged,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(color: Colors.grey),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        controller.clear();
                        onChanged?.call(''); // 清空输入框并触发验证
                      },
                    )
                        : null, // 只有有内容时显示清除按钮
                    border: InputBorder.none,
                  ),
                );
              },
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
          color: isChecked ? Colors.blue : Colors.grey, // 默认灰色，满足条件蓝色
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
  _changePassword() async {
    if(!checkEqual()){
      return ;
    }
    String account = user.getAccount();
    String newPassword=_newPasswordController.text;
    logger.i("修改密码，账户为:${account} 新密码:${newPassword}");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 获取保存的用户列表
    String? usersJson = prefs.getString('users');
    if (usersJson == null) {
      // 如果没有保存的用户信息，返回 false
      return false;
    }

    List<dynamic> usersList = json.decode(usersJson);

    // 遍历用户列表，查找匹配的账号和密码
    for (var user in usersList) {
      if (user['username'] == account ) {
        // 如果当前密码匹配，更新为新密码
        user['password'] = newPassword;

        // 保存更新后的用户列表
        String updatedUsersJson = json.encode(usersList);
        prefs.setString('users', updatedUsersJson);
        logger.i("修改成功");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('提示'),
              content: Text('密码修改成功！'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 关闭提示框


                  },
                  child: Text('确定'),
                ),
              ],
            );
          },
        );
        Navigator.pop(context);
        return true; // 密码更新成功
      }
    }

    return false; // 如果未找到匹配的账号密码，返回 false
  }

  bool checkEqual() {
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // 校验新密码与确认密码是否一致
    if (newPassword != confirmPassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('新密码与确认密码不一致'),
            content: Text('请确保新密码和确认密码相同。'),
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
      return false;
    } else {
      return true;
    }
  }
}