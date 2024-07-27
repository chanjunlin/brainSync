import 'package:flutter/cupertino.dart';

final RegExp EMAIL_VALIDATION_REGEX =
    RegExp(r'^([a-zA-Z0-9._%+-]+@gmail\.com)|([a-zA-Z0-9._%+-]+@u\.nus\.edu)$');

final RegExp PASSWORD_VALIDATION_REGEX =
    RegExp(r"^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$");

final RegExp NAME_VALIDATION_REGEX = RegExp(r'^[a-zA-Z\s]+$');

const String PLACEHOLDER_PFP =
    "https://t3.ftcdn.net/jpg/05/16/27/58/360_F_516275801_f3Fsp17x6HQK0xQgDQEELoTuERO4SsWV.jpg";

const String PLACEHOLDER_PROFILE_COVER =
    'https://www.comp.nus.edu.sg/~ngne/WEFiles/Image/Gallery/ee8928e7-a052-4ad9-9e41-be48898249fa/c835da5a-2.jpg';

String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Name is required';
  }

  if (!NAME_VALIDATION_REGEX.hasMatch(value)) {
    return 'Name can only contain letters & space';
  }

  if (value.isEmpty || value.length > 50) {
    return 'Name must be between 1 and 20 characters';
  }

  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }

  if (!EMAIL_VALIDATION_REGEX.hasMatch(value)) {
    return 'Enter a valid email address (Gmail or @u.nus.edu only)';
  }

  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }

  if (!PASSWORD_VALIDATION_REGEX.hasMatch(value)) {
    return 'Password must be at least 8 characters long, and include a mix of uppercase, lowercase letters, and digits';
  }

  return null;
}

String? validateRetypedPassword(
    String? value, TextEditingController originalPassword) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  }

  if (value != originalPassword.text) {
    return 'Passwords do not match';
  }

  return validatePassword(value);
}
