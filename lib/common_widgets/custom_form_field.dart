import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final double height;
  final RegExp validationRegEx;
  bool obscureText;
  final void Function(String?) onSaved;

  CustomFormField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.height,
    required this.validationRegEx,
    required this.onSaved,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        obscureText: obscureText,
        onSaved: onSaved,
        validator: (value) {
          if (value != null && validationRegEx.hasMatch(value)) {
            return null;
          } else {
            return "Enter a valid ${hintText.toLowerCase()}";
          }
        },
        cursorColor: Colors.brown[300],
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: Colors.brown, // Set the color to brown when focused
            ),
          ),
          labelStyle: TextStyle(
            color: Colors.brown[800],
          ),
        ),
      ),
    );
  }
}
