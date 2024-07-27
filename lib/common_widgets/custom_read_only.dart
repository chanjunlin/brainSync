import 'package:flutter/material.dart';

class CustomReadOnlyField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final double height;
  final String text;
  final Widget? suffixIcon;

  const CustomReadOnlyField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.height,
    required this.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextField(
        readOnly: true,
        controller: TextEditingController(text: text),
        cursorColor: Colors.brown[300],
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: Colors.brown.shade800,
            ),
          ),
          labelStyle: TextStyle(
            color: Colors.brown[800],
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
