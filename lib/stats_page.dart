import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/utilities/date_functions.dart';
import 'package:gratitude_app/utilities/globals.dart';


class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {

  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group)
                                                          .child(FirebaseAuth.instance.currentUser!.uid);
  StreamSubscription<DatabaseEvent>? listener;
  List<Map<dynamic, dynamic>> moods = [];
  List<FlSpot> moodSpots = [];

  @override
  void initState() {
    super.initState();
    // listener = dbRef.onValue.listen((event) async {
    //   //re-initialize moods to empty
    //   moods = [];

    //   DataSnapshot dataSnapshot = event.snapshot;
    //   if (dataSnapshot.value != null) {
    //     Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;

    //     if (values['Moods'] != null) {
    //       Map<dynamic, dynamic> logs = values['Moods'];
    //       double moodSpotIndex = 0;
    //       logs.forEach((key, value) {
    //         if (mounted) {
    //           try {
    //             setState(() {
    //               Map<dynamic, dynamic> entry = value;
    //               moods.add(entry);
    //               moodSpots.add(FlSpot(moodSpotIndex, entry['mood'].toDouble()));
    //               moodSpotIndex++;
    //           });
    //           } catch (e) {
    //             print('error with setState $e');
    //           }
    //         }
    //       });
    //     }
    //   }
    // });
  }

  Future<bool> getMoodData() async {
    final snapshot = await dbRef.child('Moods').get();
    if (snapshot.exists) {
      //re-initialize moods to empty
      moodSpots = [];
      moods = [];
      final logs = snapshot.value as Map<dynamic, dynamic>;
      print(logs);
        moods = [];
        moodSpots = [];
      logs.forEach((k,v) => moods.add(v));
      moods.sort((a, b) => a['date'].compareTo(b['date']));
      double moodSpotIndex = 0;
      for (final moodLog in moods) {
        moodSpots.add(FlSpot(moodSpotIndex, moodLog['mood'].toDouble()));
        moodSpotIndex++;
      }
      return true;
    }
    return false;
  }

  //create bottom axis widgets based on date
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    String text = '';
    try {
      text = formatDate(moods.elementAt(value.toInt())['date']);
    } catch(e) {
      print('error with creating bottom title widgets: $e');
    }
    return SideTitleWidget(
      meta: meta,
      child: Text(text), 
    );
  }

  //happy face widgets for the size
  // Widget leftTitleWidgets(double value, TitleMeta meta) {
  //   IconData icon;

  // }

  LineChartData sampleData() {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: moodSpots
          //   FlSpot(0, 1),
          //   FlSpot(1, 5),
          //   FlSpot(2, 3),
          //   FlSpot(5, 2)
          // ]
        )
      ],
      gridData: FlGridData(
        show: false
      ),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false)
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false)
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: bottomTitleWidgets,
            reservedSize: 30,
            interval: moodSpots.length/3+1,
            minIncluded: false,
            maxIncluded: false
          )
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1
          )
        )
      ),
      minY: 1,
      maxY: 5
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Text(
              'Moods',
              style: Theme.of(context).textTheme.titleMedium!,
              textAlign: TextAlign.center,
            ),
            AspectRatio(
              aspectRatio: 1.7,
              child: FutureBuilder(
                future: getMoodData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!) {
                      return LineChart(
                        sampleData()
                      );
                    } else {
                      return Center(child: Text('No mood logs yet!'));
                    }
                  }
                  return Center(child: CircularProgressIndicator());
                }
              ),
            ),
          ],
        ),
      )
    );
  }
}