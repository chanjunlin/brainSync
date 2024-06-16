import 'package:flutter/material.dart';

class CustomChatTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget leading;
  final VoidCallback onTap;

  const CustomChatTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: leading,
      title: Text(title),
      subtitle: Text(subtitle!),
    );
  }
}
