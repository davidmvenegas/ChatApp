import 'package:flutter/material.dart';

// SNACKBAR
void showSnackBar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      content: Text(message, style: const TextStyle(fontSize: 16)),
      duration: const Duration(milliseconds: 2000),
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}

void showRichTextSnackBar(
    context, color, messagePt1, highlightedText, messagePt2) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      content: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.white),
          text: messagePt1,
          children: <TextSpan>[
            TextSpan(
                text: highlightedText,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: messagePt2),
          ],
        ),
      ),
      duration: const Duration(milliseconds: 2000),
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}
