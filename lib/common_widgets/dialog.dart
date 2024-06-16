import 'package:brainsync/services/alert_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    cancelText,
                    style: TextStyle(color: Colors.brown.shade800),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[300],
                  ),
                  child: Text(
                    discardText,
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    alertService.showToast(
                      text: toastText,
                    );
                    Navigator.of(context).pop();
                    onDiscard();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
