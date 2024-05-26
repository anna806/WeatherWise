import 'package:flutter/material.dart';

import 'history_page.dart';
import 'network_service.dart';

class HistoryState extends ChangeNotifier {
  String userRole = "normal";
  List<ListItem> items = List<ListItem>.empty(growable: true);
  var datesMap = <String, List<String>>{};
  var initStarted = false;

  void setUserRole(role) {
    userRole = role;
    notifyListeners();
  }

  List<ListItem> get getItems => items;

  void initHistoryState() {
    if (initStarted) {
      return;
    }
    var service = NetworkService();
    service.getHistory(userRole, items, datesMap);
    initStarted = true;
  }

}