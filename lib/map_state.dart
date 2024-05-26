import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weather_wise/network_service.dart';
import 'city.dart';

class MapState extends ChangeNotifier {
  var countySeats = ["Bekescsaba", "Budapest", "Debrecen", "Eger", "Gyor", "Kaposvar",
    "Kecskemet", "Miskolc", "Nyiregyhaza", "Pecs", "Salgotarjan", "Szeged",
    "Szekszard", "Szekesfehervar", "Szolnok", "Szombathely", "Tatabanya", "Veszprem", "Zalaegerszeg"];
  var cities = List<City>.empty(growable: true);
  Timer? timer;
  var timerStarted = false;
  var userRole = "normal";

  void startTimer() {
    if (timerStarted) {
      return;
    }
    timer = Timer.periodic(const Duration(minutes: 1), (Timer t) => fetchWeatherData());
    fetchWeatherData();
    timerStarted = true;
  }

  void setUserRole(role) {
    userRole = role;
    notifyListeners();
  }

  List<City> get getCities => cities;
  List<String> get getCountySeats => countySeats;

  void fetchWeatherData() {
    var service = NetworkService();
    service.fetchWeatherData(userRole, countySeats, cities);
    notifyListeners();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

}