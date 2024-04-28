import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_wise/history_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(51.509364, -0.128928),
                initialZoom: 9.2,
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
                const MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(51.509364, -0.128928),
                      width: 51,
                      height: 37,
                      child: TemperatureMarker(temperature: 25),
                    ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, bottom: 70),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: const Color(0xFF8cc7ff),
                      minimumSize: const Size(double.infinity, 57),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage(items: [DateItem("Oct 22"), TemperatureItem("Budapest, HU", "9"), TemperatureItem("Szolnok, HU", "10"), TemperatureItem("Miskolc, HU", "15"), DateItem("Sept 22"), TemperatureItem("Budapest, HU", "9"), TemperatureItem("Debrecen, HU", "10"), TemperatureItem("Debrecen, HU", "10"), TemperatureItem("Debrecen, HU", "10")],)));
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
        );
    }
}

class TemperatureMarker extends StatelessWidget {
  const TemperatureMarker({super.key, required this.temperature});

  final int temperature;

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