import 'package:latlong2/latlong.dart';

class City {
  String name = "";
  String temperature = "N/A";
  LatLng coordinates = LatLng(0, 0);
  String date = "";

  City({required this.name, required this.temperature, required this.coordinates, required this.date});
}