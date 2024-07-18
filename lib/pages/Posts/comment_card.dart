import 'package:flutter/material.dart';

class CommentCard extends StatelessWidget {
  final String authorName;
  final String content;
  final String formattedDate;

  const CommentCard({
    super.key,
    required this.authorName,
    required this.content,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          authorName,
          style: TextStyle(
            fontSize: 12,
            color: Colors.brown[800],
          ),
        ),
        subtitle: Text(
          content,
          style: TextStyle(
            fontSize: 17,
            color: Colors.brown[800],
          ),
        ),
      ),
    );
  }
}
