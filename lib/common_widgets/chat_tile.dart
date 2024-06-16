import 'package:flutter/material.dart';

class CustomChatTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget leading;
  // final Widget trailing;
  final VoidCallback onTap;

  const CustomChatTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.leading,
    // required this.trailing,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: leading,
      title: Text(title),
      subtitle: Text(subtitle!),
      // trailing: trailing,
    );
  }
}
