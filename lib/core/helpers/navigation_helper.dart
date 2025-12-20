import 'package:flutter/material.dart';

class Nav {
  static to(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  static off(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  static back(BuildContext context) {
    Navigator.pop(context);
  }
}
