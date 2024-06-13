import 'package:flutter/material.dart';

class CustomFormField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final double height;
  final RegExp validationRegEx;
  final void Function(String?) onSaved;
  final bool obscureText;
  final Widget? suffixIcon; // Added suffixIcon parameter

  const CustomFormField({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.height,
    required this.validationRegEx,
    required this.onSaved,
    this.obscureText = false,
    this.suffixIcon, // Initialize suffixIcon
  }) : super(key: key);

  @override
  _CustomFormFieldState createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: TextFormField(
        obscureText: widget.obscureText ? _obscureText : false,
        onSaved: widget.onSaved,
        validator: (value) {
          if (value != null && widget.validationRegEx.hasMatch(value)) {
            return null;
          } else {
            return "Enter a valid ${widget.hintText.toLowerCase()}";
          }
        },
        cursorColor: Colors.brown[300],
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
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
          suffixIcon: widget.suffixIcon, // Use suffixIcon
        ),
      ),
    );
  }
}
