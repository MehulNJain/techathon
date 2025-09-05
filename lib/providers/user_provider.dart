import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _fullName = '';

  String get fullName => _fullName;

  void setFullName(String name) {
    _fullName = name;
    notifyListeners();
  }
}
