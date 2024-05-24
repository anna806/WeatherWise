import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_wise/history_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'city.dart';
import 'env.dart';
import 'main.dart';

class MapPage extends StatefulWidget {
  final String userRole;
  MapPage({super.key, required this.userRole});
  var countySeats = ["Bekescsaba", "Budapest", "Debrecen", "Eger", "Gyor", "Kaposvar",
    "Kecskemet", "Miskolc", "Nyiregyhaza", "Pecs", "Salgotarjan", "Szeged",
    "Szekszard", "Szekesfehervar", "Szolnok", "Szombathely", "Tatabanya", "Veszprem", "Zalaegerszeg"];
  var cities = List<City>.empty(growable: true);


  @override
  _MapPageState createState() => _MapPageState();
}



class _MapPageState extends State<MapPage> {
  Timer? timer;

  Future<Response> fetchWeather(city) {
    return http.get(Uri.parse('https://api.weatherapi.com/v1/current.json?key=${Env.weatherApiKey}=$city&aqi=no'));
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(minutes: 1), (Timer t) => fetchWeatherData(t.tick));
    fetchWeatherData(0);
  }

  void fetchWeatherData(int tick) {
    for (var city in widget.countySeats) {
      var result = fetchWeather(city);
      result.then((value) {
        Map<String, dynamic> jsonObject = jsonDecode(value.body);
        var temperature = jsonObject['current']['temp_c'].toString().substring(0, 2);
        var resultCity = City(name: (jsonObject['location']['name'] + ", HU"), temperature: temperature, coordinates: LatLng(jsonObject['location']['lat'], jsonObject['location']['lon']), date: jsonObject['location']['localtime']);
        setState(() {
          widget.cities.add(resultCity);
        });
        if(widget.userRole == "admin") {
          saveWeatherData(resultCity);
        }
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child:
        SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(47.49791200,19.04023500),
                    initialZoom: 7.0,
                    interactionOptions: InteractionOptions(
                      enableMultiFingerGestureRace: true,
                      flags: InteractiveFlag.doubleTapDragZoom |
                      InteractiveFlag.doubleTapZoom |
                      InteractiveFlag.drag |
                      InteractiveFlag.flingAnimation |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.scrollWheelZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'weather_wise',
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        for (var city in widget.cities)
                          Marker(
                            point: city.coordinates,
                            width: 51,
                            height: 37,
                            child: TemperatureMarker(temperature: city.temperature),
                          ),
                      ],
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, right: 10),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF8cc7ff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Log out"),
                              content: const Text("Are you sure you want to log out?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("No"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (_) => false);
                                  },
                                  child: const Text("Yes"),
                                ),
                              ],
                            );
                          },
                        );

                      },
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                      )
                    )
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 70),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF8cc7ff),
                          minimumSize: const Size(double.infinity, 57),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage(userRole: widget.userRole)));
                        },
                        child: Text('See history', style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white
                            )
                        )),
                      ),
                    )
                  )
                ],
               )
              ),
          )
        );
    }
}

class TemperatureMarker extends StatelessWidget {
  const TemperatureMarker({super.key, required this.temperature});

  final String temperature;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5)
      ),
      child: Center(
        child: Text(
          '$temperature°C',
          style: GoogleFonts.poppins(
            color: const Color(0xFF8cc7ff),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          )
        ),
      ),
    );
  }
}