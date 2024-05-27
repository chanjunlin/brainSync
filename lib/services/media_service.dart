import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  MediaService() {}

  Future<File?> getImageFromGallery() async {
    final XFile? _file = await _picker.pickImage(source: ImageSource.gallery);
    if (_file != null) {
      return File(_file!.path);
    }
    return null;
  }

  Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      print('Image path: ${image.path}');
      return File(image!.path);
    } else {
      print('No image selected.');
    }
  }
}
