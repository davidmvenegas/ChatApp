import 'package:flutter/material.dart';

// NEXT SCREEN
nextScreen(context, page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}

// NEXT SCREEN REPLACE
nextScreenReplace(context, page) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}
