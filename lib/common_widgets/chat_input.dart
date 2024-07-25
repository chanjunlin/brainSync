import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

class AnimatedChatList extends StatefulWidget {
  final List<ChatMessage> messages;

  const AnimatedChatList({super.key, required this.messages});

  @override
  _AnimatedChatListState createState() => _AnimatedChatListState();
}

class _AnimatedChatListState extends State<AnimatedChatList> {
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
        return _buildMessage(_messages[index], animation);
      },
    );
  }

  Widget _buildMessage(ChatMessage message, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: ListTile(
          title: Text(message.text ?? ''),
          subtitle: Text(message.user.firstName!),
          // Add more styling based on message properties
        ),
      ),
    );
  }

  void insertMessage(ChatMessage message) {
    setState(() {
      _messages.insert(0, message); // Add to the beginning of the list
      _listKey.currentState?.insertItem(0);
    });
  }

  void removeMessage(int index) {
    final removedMessage = _messages[index];
    setState(() {
      _messages.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
            (context, animation) => _buildMessage(removedMessage, animation),
      );
    });
  }
}
