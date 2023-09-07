import 'package:flutter/material.dart';
import 'package:time_planner/src/config/global_config.dart' as config;

/// Title widget for time planner
class TimePlannerTitle extends StatelessWidget {
  /// Title of each day, typically is name of the day for example sunday
  ///
  /// but you can set any things here
  final String title;

  /// Text style for title
  final TextStyle? titleStyle;

  /// Date of each day like 03/21/2021 but you can leave it empty or write other things
  final String? date;

  /// Text style for date text
  final TextStyle? dateStyle;

  /// Image url for circle avatar
  final String imageUrl;

  /// Title widget for time planner
  const TimePlannerTitle({
    Key? key,
    required this.title,
    this.date,
    this.titleStyle,
    this.dateStyle,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: config.cellWidth!.toDouble(),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: const Color.fromRGBO(36, 107, 254, 1),
              child: imageUrl != ""
                  ? const SizedBox()
                  : Text(
                      title.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            Text(title)
          ],
        ),
      ),
    );
  }
}
