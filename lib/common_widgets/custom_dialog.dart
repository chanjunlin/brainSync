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
          backgroundColor: Colors.white,
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  content,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.brown[600]),
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(120, 50),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          color: Colors.brown.shade800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[300],
                        minimumSize: const Size(120, 50),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
