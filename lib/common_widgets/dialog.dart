import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/alert_service.dart';

class CustomDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String content,
    required String cancelText,
    required String discardText,
    required String toastText,
    required VoidCallback onDiscard,
  }) {
    final alertService = GetIt.instance<AlertService>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                content,
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.brown[600]),
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      cancelText,
                      style: TextStyle(color: Colors.brown.shade800),
                    ),
                  ),
                ),
                Flexible(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[300],
                    ),
                    onPressed: () {
                      alertService.showToast(
                        text: toastText,
                      );
                      Navigator.of(context).pop();
                      onDiscard();
                    },
                    child: Text(
                      discardText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
