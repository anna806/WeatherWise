import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import '../map_page.dart';
import 'months.dart';

class HistoryPage extends StatefulWidget {
  final String userRole;
  final List<ListItem> items = List<ListItem>.empty(growable: true);
  var datesMap = <String, List<String>>{};

  HistoryPage({super.key, required this.userRole});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  @override
  void initState() {
    super.initState();
    getHistory();
  }

  void getHistory() {
    var historicalData = FirebaseFirestore.instance.collection('WeatherData');
    historicalData.get().then((QuerySnapshot querySnapshot) {
      var reversedDocs = querySnapshot.docs.reversed.toList();
      for (var doc in reversedDocs) {
        handleDate(doc);
      }
    });
  }

  void handleDate(doc) {
    if (widget.userRole == "admin") {
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
      setState(() {
        widget.items.addAll(dateList);
      });
    }
    else if (widget.userRole == "normal") {
      var dateList = List<ListItem>.empty(growable: true);
      var newDate = doc['date'];
      var datePieces = newDate.split("-");
      var day = datePieces[2][0] + datePieces[2][1];
      var month = getMonths(datePieces[1]);
      newDate = [month, day].join(" ");
      if (!widget.datesMap.keys.contains(newDate)) {
        dateList.add(DateItem(newDate));
        widget.datesMap[newDate] = [];
      }
      for (var city in doc['cities']) {
        if(!widget.datesMap[newDate]!.contains(city['name'])) {
          dateList.add(TemperatureItem(city['name'], city['temperature']));
          widget.datesMap[newDate]?.add(city['name']);
        }
      }
      setState(() {
        widget.items.addAll(dateList);
      });
    }

  }

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
                /*ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 580
                    ),*/
                Expanded(
                  flex: 4,
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
                  flex: 1,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30, top: 16, bottom: 25),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: const Color(0xFF8cc7ff),
                                minimumSize: const Size(double.infinity, 57),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder:
                                    (context) => MapPage(userRole: widget.userRole)));
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
                Expanded(
                    child:
                        Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child:
                                Text(
                                    city,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF000000),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    )
                                ),
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