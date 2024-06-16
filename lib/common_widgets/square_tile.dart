import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final void Function() onTap;
  final String? label; // Add an optional label parameter

  const SquareTile({
    super.key,
    required this.imagePath,
    required this.onTap,
    this.label, // Accept the optional label parameter
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.asset(
        imagePath,
        width: 24,
        height: 24,
      ),
      label: Text(label ?? ""),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.brown[300],
        minimumSize: const Size(200, 50), // Adjust as needed
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}
