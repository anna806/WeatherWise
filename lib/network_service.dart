import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import 'city.dart';
import 'env.dart';
import 'history_page.dart';
import 'months.dart';

class NetworkService {

  void fetchWeatherData(String userRole, countySeats, cities) {
    for (var city in countySeats) {
      var result = fetchWeather(city);
      result.then((value) {
        Map<String, dynamic> jsonObject = jsonDecode(value.body);
        var temperature = jsonObject['current']['temp_c'].toString().substring(0, 2);
        var resultCity = City(name: (jsonObject['location']['name'] + ", HU"), temperature: temperature, coordinates: LatLng(jsonObject['location']['lat'], jsonObject['location']['lon']), date: jsonObject['location']['localtime']);
        cities.removeWhere((element) => element.name == resultCity.name);
        cities.add(resultCity);
        if(userRole == "admin") {
          saveWeatherData(resultCity);
        }
      });
    }
  }

  Future<Response> fetchWeather(city) {
    return http.get(Uri.parse('https://api.weatherapi.com/v1/current.json?key=${Env.weatherApiKey}=$city&aqi=no'));
  }

  void saveWeatherData(city) {
    Map<String, dynamic> cityMap = {
      'name': city.name,
      'temperature': city.temperature,
      'coordinates': {
        'lat': city.coordinates.latitude,
        'lon': city.coordinates.longitude
      },
      'date': city.date
    };
    var db = FirebaseFirestore.instance.collection("WeatherData");
    var exists = false;
    db.doc(city.date).get().then((docSnapshot) {
      if (docSnapshot.exists) {
        db.doc(city.date).update({
          'cities': FieldValue.arrayUnion([cityMap])
        });
        exists = true;
      }
    });
    if (!exists) {
      db.doc(city.date).set({
        'date': city.date,
        'cities': [cityMap]
      });
    }
  }

  void getHistory(userRole, items, datesMap) {
    var historicalData = FirebaseFirestore.instance.collection('WeatherData');
    historicalData.get().then((QuerySnapshot querySnapshot) {
      var reversedDocs = querySnapshot.docs.reversed.toList();
      for (var doc in reversedDocs) {
        handleDate(doc, userRole, items, datesMap);
      }
    });
  }

  void handleDate(doc, userRole, items, datesMap) {
    if (userRole == "admin") {
      var dateList = List<ListItem>.empty(growable: true);
      var date = doc['date'];
      date = date.replaceAll("-", " ");

      var datePieces = date.split(" ");
      var month = getMonths(datePieces[1]);
      date = [datePieces[2], month, datePieces[0], datePieces[3]].join(" ");
      dateList.add(DateItem(date));
      for (var city in doc['cities']) {
        dateList.add(TemperatureItem(city['name'], city['temperature']));
      }
      items.addAll(dateList);
    }
    else if (userRole == "normal") {
      var dateList = List<ListItem>.empty(growable: true);
      var newDate = doc['date'];
      var datePieces = newDate.split("-");
      var day = datePieces[2][0] + datePieces[2][1];
      var month = getMonths(datePieces[1]);
      newDate = [month, day].join(" ");
      if (!datesMap.keys.contains(newDate)) {
        dateList.add(DateItem(newDate));
        datesMap[newDate] = List<String>.empty(growable: true);
      }
      for (var city in doc['cities']) {
        if(!datesMap[newDate]!.contains(city['name'])) {
          dateList.add(TemperatureItem(city['name'], city['temperature']));
          datesMap[newDate]?.add(city['name']);
        }
      }
      items.addAll(dateList);
    }
  }
}