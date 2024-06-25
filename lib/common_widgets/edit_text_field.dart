import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController textController;
  final String labelText;
  final double vertical, horizontal;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.textController,
    required this.labelText,
    required this.vertical,
    required this.horizontal,
    required this.maxLines,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textController,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: Colors.brown.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.brown.shade300,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.brown.shade800,
            width: 1.0,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
            horizontal: widget.horizontal, vertical: widget.vertical),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your ${widget.labelText}';
        }
        return null;
      },
    );
  }
}
