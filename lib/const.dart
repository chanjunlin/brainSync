import 'package:flutter/cupertino.dart';

final RegExp EMAIL_VALIDATION_REGEX =
    RegExp(r'^([a-zA-Z0-9._%+-]+@gmail\.com)|([a-zA-Z0-9._%+-]+@u\.nus\.edu)$');

final RegExp PASSWORD_VALIDATION_REGEX =
    RegExp(r"^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$");

final RegExp NAME_VALIDATION_REGEX = RegExp(r'^[a-zA-Z\s]+$');

const String PLACEHOLDER_PFP =
    "https://t3.ftcdn.net/jpg/05/16/27/58/360_F_516275801_f3Fsp17x6HQK0xQgDQEELoTuERO4SsWV.jpg";

const String PLACEHOLDER_PROFILE_COVER =
    'https://firebasestorage.googleapis.com/v0/b/brainsync6325.appspot.com/o/brainsync.png?alt=media&token=6f290b30-f675-4aae-a1c9-75084c49840f';

String? validateFirstName(String? value) {
  if (value == null || value.isEmpty) {
    return 'First name is required';
  }

  if (!NAME_VALIDATION_REGEX.hasMatch(value)) {
    return 'First name can only contain letters & space';
  }

  if (value.isEmpty || value.length > 50) {
    return 'First name must be between 1 and 20 characters';
  }

  return null;
}

String? validateLastName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Last name is required';
  }

  if (!NAME_VALIDATION_REGEX.hasMatch(value)) {
    return 'Last name can only contain letters & space';
  }

  if (value.isEmpty || value.length > 50) {
    return 'Last name must be between 1 and 20 characters';
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

  if (value.length < 8 || value.isEmpty) {
    return 'Password must be at least 8 characters long';
  }

  if (!PASSWORD_VALIDATION_REGEX.hasMatch(value)) {
    return 'Password must include Uppercase and lowercase letters, numbers and special characters';
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
