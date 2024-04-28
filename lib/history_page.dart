import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'map_page.dart';

class HistoryPage extends StatefulWidget {
  final List<ListItem> items;

  const HistoryPage({super.key, required this.items});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        body: SafeArea (
          child: Center(
            child: Column(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8cc7ff),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(25.0),
                      ),
                    ),
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Text("History", style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white
                                  ))
                              ),
                            ]
                        )
                    )
                ),
                ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 580
                    ),
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];

                        return item.buildItem(context);
                      }
                  )
                ),
                Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30, top: 16, bottom: 45),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: const Color(0xFF8cc7ff),
                                minimumSize: const Size(double.infinity, 57),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder:
                                    (context) => const MapPage()));
                              },
                              child: Text(
                                  "See map",
                                  style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white
                                      )
                                  )
                              )
                          )
                      ),
                    )
                )
              ],
            )

          )
        )
    );
  }


}


abstract class ListItem {
  Widget buildItem(BuildContext context);
}

class DateItem implements ListItem {
  final String date;

  DateItem(this.date);

  @override
  Widget buildItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, top: 16),
      child: Text(
          date,
          style: GoogleFonts.poppins(
            color: const Color(0xFF000000).withOpacity(0.6),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
      )
    );
  }
}

class TemperatureItem implements ListItem {
  final String city;
  final String temperature;

  TemperatureItem(this.city, this.temperature);

  @override
  Widget buildItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: Container (
        height: 82,
        width: 350,
        decoration: BoxDecoration (
          boxShadow: [
            BoxShadow (
              color: const Color(0xFF00000f).withOpacity(0.06),
              blurRadius: 20.0,
              spreadRadius: 0.0,
              offset: const Offset(0, 4)
                  ),
              ]
        ),
        child: Card(
            surfaceTintColor: const Color(0xFFFFFFFF),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Image(image: AssetImage('assets/images/cloud.png'))
                ),
                Text(
                    city,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF000000),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    )
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                        "$temperature°C",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF8cc7ff),
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        )
                    )
                )
              ],
            )
        ),
      )
    );
  }

}