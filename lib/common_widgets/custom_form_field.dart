import 'package:flutter/material.dart';

class CustomFormField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final double height;
  final FormFieldValidator<String>? validator;
  final void Function(String?) onSaved;
  final bool obscureText;
  final Widget? suffixIcon;

  const CustomFormField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.height,
    required this.validator,
    required this.onSaved,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  CustomFormFieldState createState() => CustomFormFieldState();
}

class CustomFormFieldState extends State<CustomFormField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.height,
          child: TextFormField(
            obscureText: widget.obscureText ? _obscureText : false,
            onSaved: widget.onSaved,
            validator: widget.validator,
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
              suffixIcon: widget.suffixIcon,
              errorMaxLines: 5,
            ),
          ),
        ),
      ],
    );
  }
}
