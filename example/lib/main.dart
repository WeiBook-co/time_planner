import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:time_planner/time_planner.dart';

void main() {
  runApp(const MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time planner Demo',
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Time planner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TimePlannerTask> tasks = [];

  void _addObject(BuildContext context) {
    List<Color?> colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.lime[600]
    ];

    setState(() {
      tasks.add(
        TimePlannerTask(
          color: colors[Random().nextInt(colors.length)],
          dateTime: TimePlannerDateTime(
              day: Random().nextInt(14),
              hour: Random().nextInt(18) + 6,
              minutes: Random().nextInt(60)),
          minutesDuration: Random().nextInt(90) + 30,
          daysDuration: Random().nextInt(4) + 1,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('You click on time planner object')));
          },
          child: Text(
            'this is a demo',
            style: TextStyle(color: Colors.grey[350], fontSize: 12),
          ),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Random task added to time planner!')));
  }

  void _handleCellTap(int dayIndex, int hour) {
    TimePlannerTask newEvent = TimePlannerTask(
      minutesDuration: 60,
      dateTime: TimePlannerDateTime(day: dayIndex, hour: hour, minutes: 60),
      color: Colors.blue,
      onTap: () {},
    );
    setState(() {
      tasks.add(newEvent);
    });
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Event'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      setState(() {
        tasks.remove(newEvent);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: Center(
          child: TimePlanner(
            onTapCalendar: _handleCellTap,
            startHour: 6,
            endHour: 23,
            use24HourFormat: false,
            setTimeOnAxis: false,
            style: TimePlannerStyle(
              // cellHeight: 60,
              // cellWidth: 60,
              showScrollBar: true,
              interstitialEvenColor: Colors.white,
              interstitialOddColor: Colors.white,
            ),
            headers: [
              TimePlannerTitle(
                title: 'Monday',
                date: '03/21/2022',
                imageUrl: '',
                blockedRanges: [
                  TimeRange(
                      start: TimeOfDay(hour: 6, minute: 0),
                      end: TimeOfDay(hour: 9, minute: 10)),
                  TimeRange(
                      start: TimeOfDay(hour: 17, minute: 30),
                      end: TimeOfDay(hour: 23, minute: 0)),
                ],
              ),
              TimePlannerTitle(
                title: 'Tuesday',
                date: '03/22/2022',
                imageUrl: '',
                blockedRanges: [
                  TimeRange(
                      start: TimeOfDay(hour: 6, minute: 0),
                      end: TimeOfDay(hour: 10, minute: 0)),
                  TimeRange(
                      start: TimeOfDay(hour: 18, minute: 45),
                      end: TimeOfDay(hour: 23, minute: 0)),
                ],
              ),
            ],
            tasks: tasks,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addObject(context),
          tooltip: 'Add random task',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
