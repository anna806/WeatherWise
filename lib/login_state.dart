import 'package:flutter/material.dart';

class LoginState extends ChangeNotifier {
  var _isLoading = false;

  bool get isLoading => _isLoading;

  void setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }
}