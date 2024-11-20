import 'package:flutter/material.dart';
import 'model/entity/Message.dart';
import 'model/entity/User.dart';

class InnerMessage {
  final String userName;
  final String imageUrl;
  final String message;
  final bool isSentByUser;

  InnerMessage({
    required this.userName,
    required this.imageUrl,
    required this.message,
    required this.isSentByUser,
  });
}

class ChatScreen extends StatefulWidget {
  final Message message;
  final User user;

  ChatScreen({required this.message, required this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<InnerMessage> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    messages.add(InnerMessage(
      userName: widget.message.userName,
      imageUrl: widget.message.imageUrl,
      message: widget.message.lastMessage,
      isSentByUser: false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: Text(widget.message.userName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromRGBO(240, 244, 255, 1),
      ),
      body: Container(
        color: const Color.fromRGBO(238, 237, 242, 1),
        child: Column(
          children: [
            //消息列表
            getMsgList(),
            //输入框
            getInputBox(),
          ],
        ),
      ),
    );
  }

  Widget getMsgList() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return Align(
            alignment: messages[index].isSentByUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!messages[index].isSentByUser)
                    CircleAvatar(
                      backgroundImage: NetworkImage(messages[index].imageUrl),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    constraints: const BoxConstraints(
                      maxWidth: 270.0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                    decoration: BoxDecoration(
                      color: messages[index].isSentByUser ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      messages[index].message,
                      style: TextStyle(
                        color: messages[index].isSentByUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  if (messages[index].isSentByUser) const SizedBox(width: 8),
                  if (messages[index].isSentByUser)
                    CircleAvatar(
                      backgroundImage: NetworkImage(messages[index].imageUrl),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getInputBox() {
    return Container(
      color: const Color.fromRGBO(243, 242, 247, 1),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(17, 10, 17, 17),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "输入消息...",
                    border: InputBorder.none,

                  ),
                  onChanged: (text) {
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),

            Visibility(
              visible: _controller.text.trim().isNotEmpty,
              child: Container(
                width: 65,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    String text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      InnerMessage newMessage = InnerMessage(
                        userName: widget.user.getUserName(),
                        imageUrl: widget.user.getImageUrl(),
                        message: text,
                        isSentByUser: true,
                      );
                      setState(() {
                        messages.add(newMessage);
                      });
                      _controller.clear();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
