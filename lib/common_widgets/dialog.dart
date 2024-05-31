import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:brainsync/services/alert_service.dart';

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
    final getIt = GetIt.instance;
    final AlertService _alertService = getIt<AlertService>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      content,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  child: Text(
                    cancelText,
                    style: TextStyle(color: Colors.brown.shade800),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.brown[300],
                  ),
                  child: Text(discardText),
                  onPressed: () {
                    _alertService.showToast(
                      text: "$toastText",
                    );
                    Navigator.of(context).pop(); // Close the dialog
                    onDiscard(); // Perform the discard action
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
