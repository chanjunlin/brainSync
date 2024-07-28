import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

class AnimatedChatList extends StatefulWidget {
  final List<ChatMessage> messages;

  const AnimatedChatList({super.key, required this.messages});

  @override
  AnimatedChatListState createState() => AnimatedChatListState();
}

class AnimatedChatListState extends State<AnimatedChatList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = widget.messages;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _messages.length,
      itemBuilder: (context, index, animation) {
        return buildMessage(_messages[index], animation);
      },
    );
  }

  Widget buildMessage(ChatMessage message, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: ListTile(
          title: Text(message.text),
          subtitle: Text(
            message.user.firstName!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  void insertMessage(ChatMessage message) {
    setState(() {
      _messages.insert(0, message);
      _listKey.currentState?.insertItem(0);
    });
  }

  void removeMessage(int index) {
    final removedMessage = _messages[index];
    setState(() {
      _messages.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => buildMessage(removedMessage, animation),
      );
    });
  }
}
