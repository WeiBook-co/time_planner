import 'package:flutter/material.dart';
import 'package:time_planner/src/config/global_config.dart' as config;
import 'package:time_planner/src/time_planner_style.dart';
import 'package:time_planner/src/time_planner_task.dart';
import 'package:time_planner/src/time_planner_time.dart';
import 'package:time_planner/src/time_planner_title.dart';

class DiagonalLinesPainter extends CustomPainter {
  final Color color;
  final double lineWidth;
  final double spacing;

  DiagonalLinesPainter({
    required this.color,
    this.lineWidth = 2.0,
    this.spacing = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    // Dibujar líneas diagonales dentro del contenedor de tamaño fijo
    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
          Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Time planner widget
class TimePlanner extends StatefulWidget {
  /// Time start from this, it will start from 0
  final int startHour;

  /// Time end at this hour, max value is 23
  final int endHour;

  /// Create days from here, each day is a TimePlannerTitle.
  ///
  /// you should create at least one day
  final List<TimePlannerTitle> headers;

  /// List of widgets on time planner
  final List<TimePlannerTask>? tasks;

  /// Style of time planner
  final TimePlannerStyle? style;

  /// When widget loaded scroll to current time with an animation. Default is true
  final bool? currentTimeAnimation;

  /// Whether time is displayed in 24 hour format or am/pm format in the time column on the left.
  final bool use24HourFormat;

  //Whether the time is displayed on the axis of the tim or on the center of the timeblock. Default is false.
  final bool setTimeOnAxis;

  /// Dynamic function to set an event when a cell is clicked on
  final Function onTapCalendar;

  /// Time planner widget
  const TimePlanner({
    Key? key,
    required this.startHour,
    required this.endHour,
    required this.headers,
    required this.onTapCalendar,
    this.tasks,
    this.style,
    this.use24HourFormat = false,
    this.setTimeOnAxis = false,
    this.currentTimeAnimation,
  }) : super(key: key);

  @override
  _TimePlannerState createState() => _TimePlannerState();
}

class _TimePlannerState extends State<TimePlanner> {
  ScrollController mainHorizontalController = ScrollController();
  ScrollController mainVerticalController = ScrollController();
  ScrollController dayHorizontalController = ScrollController();
  ScrollController timeVerticalController = ScrollController();
  TimePlannerStyle style = TimePlannerStyle();
  List<TimePlannerTask> tasks = [];
  bool? isAnimated = true;

  /// check input value rules
  void _checkInputValue() {
    if (widget.startHour > widget.endHour) {
      throw FlutterError("Start hour should be lower than end hour");
    } else if (widget.startHour < 0) {
      throw FlutterError("Start hour should be larger than 0");
    } else if (widget.endHour > 23) {
      throw FlutterError("Start hour should be lower than 23");
    } else if (widget.headers.isEmpty) {
      throw FlutterError("header can't be empty");
    }
  }

  /// create local style
  void _convertToLocalStyle() {
    style.backgroundColor = widget.style?.backgroundColor;
    style.cellHeight = widget.style?.cellHeight ?? 80;
    style.cellWidth = widget.style?.cellWidth ?? 90;
    style.horizontalTaskPadding = widget.style?.horizontalTaskPadding ?? 0;
    style.borderRadius = widget.style?.borderRadius ??
        const BorderRadius.all(Radius.circular(8.0));
    style.dividerColor = widget.style?.dividerColor;
    style.showScrollBar = widget.style?.showScrollBar ?? false;
    style.interstitialOddColor = widget.style?.interstitialOddColor;
    style.interstitialEvenColor = widget.style?.interstitialEvenColor;
  }

  /// store input data to static values
  void _initData() {
    _checkInputValue();
    _convertToLocalStyle();
    config.horizontalTaskPadding = style.horizontalTaskPadding;
    config.cellHeight = style.cellHeight;
    config.cellWidth = style.cellWidth;
    config.totalHours = (widget.endHour - widget.startHour).toDouble();
    config.totalDays = widget.headers.length;
    config.startHour = widget.startHour;
    config.use24HourFormat = widget.use24HourFormat;
    config.setTimeOnAxis = widget.setTimeOnAxis;
    config.borderRadius = style.borderRadius;
    isAnimated = widget.currentTimeAnimation;
    tasks = widget.tasks ?? [];
  }

  @override
  void initState() {
    _initData();
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      int hour = DateTime.now().hour;
      if (isAnimated != null && isAnimated == true) {
        if (hour > widget.startHour) {
          double scrollOffset =
              (hour - widget.startHour) * config.cellHeight!.toDouble();
          mainVerticalController.animateTo(
            scrollOffset,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCirc,
          );
          timeVerticalController.animateTo(
            scrollOffset,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCirc,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tasks = widget.tasks ?? [];
    mainHorizontalController.addListener(() {
      dayHorizontalController.jumpTo(mainHorizontalController.offset);
    });
    mainVerticalController.addListener(() {
      timeVerticalController.jumpTo(mainVerticalController.offset);
    });

    return GestureDetector(
      child: Container(
        color: style.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SingleChildScrollView(
              controller: dayHorizontalController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(
                    width: 60,
                  ),
                  for (int i = 0; i < config.totalDays; i++) widget.headers[i],
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: timeVerticalController,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              for (int i = widget.startHour;
                                  i <= widget.endHour;
                                  i++)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        !config.use24HourFormat ? 10 : 0,
                                  ),
                                  child: TimePlannerTime(
                                    time: formattedTime(i),
                                    setTimeOnAxis: config.setTimeOnAxis,
                                  ),
                                )
                            ],
                          ),
                          Container(
                            height:
                                (config.totalHours * config.cellHeight!) + 80,
                            width: 1,
                            color: style.dividerColor ??
                                Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: buildMainBody(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget buildMainBody() {
  GlobalKey hourKey = GlobalKey();

  List<Widget> buildBlockedAreas() {
    List<Widget> blockedAreas = [];

    for (var dayIndex = 0; dayIndex < config.totalDays; dayIndex++) {
      var blockedRanges = widget.headers[dayIndex].blockedRanges;

      for (var range in blockedRanges) {
        var startHour = range.start.hour;
        var startMinute = range.start.minute;
        var endHour = range.end.hour;
        var endMinute = range.end.minute;

        // Calcular la posición y tamaño del bloque
        double topPosition =
            ((startHour - widget.startHour) * config.cellHeight! +
                    (startMinute / 60) * config.cellHeight!)
                .toDouble();
        double height = ((endHour - startHour) * config.cellHeight! +
                ((endMinute - startMinute) / 60) * config.cellHeight!)
            .toDouble();

        blockedAreas.add(Positioned(
          top: topPosition,
          left: (dayIndex * config.cellWidth!).toDouble(),
          width: config.cellWidth!.toDouble(),
          height: height,
          child: IgnorePointer(
            child: Container(
              color: Colors.grey.withOpacity(0.2),
              child: ClipRect(
                child: CustomPaint(
                  size: Size(config.cellWidth!.toDouble(), height),
                  painter: DiagonalLinesPainter(
                    color: Colors.grey.withOpacity(0.8),
                    lineWidth: 1.0,
                    spacing: 10.0,
                  ),
                ),
              ),
            ),
          ),
        ));
      }
    }

    return blockedAreas;
  }

  return SingleChildScrollView(
    controller: mainVerticalController,
    child: SingleChildScrollView(
      controller: mainHorizontalController,
      scrollDirection: Axis.horizontal,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: (config.totalHours * config.cellHeight!) + 80,
                    width: (config.totalDays * config.cellWidth!).toDouble(),
                    child: Stack(
                      children: <Widget>[
                        Column(
                          key: hourKey,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            for (var i = 0; i < config.totalHours; i++)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    height: (config.cellHeight! - 1).toDouble(),
                                    color: i.isOdd
                                        ? style.interstitialOddColor
                                        : style.interstitialEvenColor,
                                  ),
                                  const Divider(
                                    height: 1,
                                  ),
                                ],
                              )
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            for (var i = 0; i < config.totalDays; i++)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Column(
                                    children: [
                                      for (var j = 0; j < config.totalHours; j++)
                                        Column(
                                          children: [
                                            for (var k = 0; k < 2; k++)
                                              InkWell(
                                                onTapDown: (details) {
                                                  // Manejo del tap en las casillas
                                                  final RenderBox box =
                                                      context.findRenderObject()
                                                          as RenderBox;
                                                  final Offset localOffset = box
                                                      .globalToLocal(details
                                                          .globalPosition);
                                                  final double verticalOffset =
                                                      mainVerticalController
                                                          .offset;

                                                  final double relativeY =
                                                      localOffset.dy +
                                                          verticalOffset;

                                                  final double heightColumn =
                                                      hourKey.currentContext!
                                                          .findRenderObject()!
                                                          .paintBounds
                                                          .size
                                                          .height;

                                                  final double heightBlock =
                                                      heightColumn /
                                                          config.totalHours;

                                                  if (relativeY >= heightBlock &&
                                                      relativeY <=
                                                          heightBlock * 2) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour - 1);
                                                  } else if (relativeY >=
                                                          (heightBlock * 2) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 3) {
                                                    widget.onTapCalendar(
                                                        i, widget.startHour);
                                                  } else if (relativeY >=
                                                          (heightBlock * 3) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 4) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 1);
                                                  } else if (relativeY >=
                                                          (heightBlock * 4) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 5) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 2);
                                                  } else if (relativeY >=
                                                          (heightBlock * 5) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 6) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 3);
                                                  } else if (relativeY >=
                                                          (heightBlock * 6) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 7) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 4);
                                                  } else if (relativeY >=
                                                          (heightBlock * 7) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 8) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 5);
                                                  } else if (relativeY >=
                                                          (heightBlock * 8) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 9) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 6);
                                                  } else if (relativeY >=
                                                          (heightBlock * 9) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 10) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 7);
                                                  } else if (relativeY >=
                                                          (heightBlock * 10) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 11) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 8);
                                                  } else if (relativeY >=
                                                          (heightBlock * 11) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 12) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 9);
                                                  } else if (relativeY >=
                                                          (heightBlock * 12) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 13) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 10);
                                                  } else if (relativeY >=
                                                          (heightBlock * 13) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 14) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 11);
                                                  } else if (relativeY >=
                                                          (heightBlock * 14) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 15) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 12);
                                                  } else if (relativeY >=
                                                          (heightBlock * 15) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 16) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 13);
                                                  } else if (relativeY >=
                                                          (heightBlock * 16) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 17) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 14);
                                                  } else if (relativeY >=
                                                          (heightBlock * 17) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 18) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 15);
                                                  } else if (relativeY >=
                                                          (heightBlock * 18) + 1 &&
                                                      relativeY <=
                                                          heightBlock * 19) {
                                                    widget.onTapCalendar(i,
                                                        widget.startHour + 16);
                                                  }
                                                },
                                                child: Container(
                                                  width: (config.cellWidth! - 1)
                                                      .toDouble(),
                                                  height:
                                                      (config.cellHeight! / 2 - 1)
                                                          .toDouble(),
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: (config.totalHours *
                                            config.cellHeight!) +
                                        config.cellHeight!,
                                    color: Colors.black12,
                                  ),
                                ],
                              )
                          ],
                        ),
                        for (int i = 0; i < tasks.length; i++) tasks[i],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          ...buildBlockedAreas(),
        ],
      ),
    ),
  );
}

  String formattedTime(int hour) {
    if (config.use24HourFormat) {
      return hour.toString() + ':00';
    } else {
      if (hour == 0) return "12:00 am";
      if (hour < 12) return "$hour:00 am";
      if (hour == 12) return "12:00 pm";
      return "${hour - 12}:00 pm";
    }
  }
}
