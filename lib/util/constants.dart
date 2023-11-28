import 'package:flutter/material.dart';

const spinner = Center(
  child: CircularProgressIndicator(),
);

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }

  showConfirmationDialog(
      {String? title,
      String? message,
      String? cancelText,
      String? confirmText,
      Function()? onCancel,
      Function()? onConfirm}) {
    return showDialog(
      context: this,
      builder: (context) => AlertDialog(
        title: title != null ? Text(title) : null,
        content: message != null ? Text(message) : null,
        contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
        actions: [
          TextButton(
            onPressed: () {
              onCancel?.call();
              Navigator.of(context).pop(false);
            },
            child: Text(cancelText ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirm?.call();
              Navigator.of(context).pop(true);
            },
            child: Text(confirmText ?? 'Confirm'),
          ),
        ],
      ),
    );
  }
}

const creamerOptions = [
  'No Creamer',
  'One Creamers',
  'Two Creamers',
  'Three Creamers',
  'Four Creamers',
];

const frequencyOptions = [
  'Tuesday Only',
  'Friday Only',
  'Every Enrichment (Tue/Fri)',
];
