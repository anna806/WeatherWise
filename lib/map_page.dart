import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_wise/history_page.dart';
import 'history_state.dart';
import 'main.dart';
import 'map_state.dart';

class MapPage extends StatelessWidget {
  final String userRole;
  MapPage({super.key, required this.userRole});
  Timer? timer;

  Future<void> initMapState(BuildContext context) async {
    await Future.delayed(Duration.zero);
    Provider.of<MapState>(context, listen: false).setUserRole(userRole);
    Provider.of<MapState>(context, listen: false).startTimer();
  }

  @override
  Widget build(BuildContext context) {
    initMapState(context);
    var cities = Provider.of<MapState>(context).getCities;
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
                          for (var city in cities)
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
                                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (_) => false);
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage(userRole: userRole)));
                            Provider.of<HistoryState>(context, listen: false).initStarted = false;
                            Provider.of<HistoryState>(context, listen: false).items = List<ListItem>.empty(growable: true);
                            Provider.of<HistoryState>(context, listen: false).datesMap = <String, List<String>>{};
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