// lib/utils/dialogs.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows a confirmation dialog and exits the app if confirmed.
void showExitConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit CaseNext?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close the dialog
            },
          ),
          ElevatedButton(
            onPressed: () {
              // Exit the application
              SystemNavigator.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      );
    },
  );
}