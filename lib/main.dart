// main.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tracking_app/models/time_data.dart';
import 'package:time_tracking_app/procrastinating_page.dart';
import 'package:time_tracking_app/widget/time_ratio.dart';
import 'package:time_tracking_app/working_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  runApp(const TimeTrackingApp());
}

class TimeTrackingApp extends StatelessWidget {
  const TimeTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Time Track',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        primaryTextTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).primaryTextTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const TimeTrackingHomePage(),
    );
  }
}

class TimeTrackingHomePage extends StatefulWidget {
  const TimeTrackingHomePage({super.key});

  @override
  TimeTrackingHomePageState createState() => TimeTrackingHomePageState();
}

class TimeTrackingHomePageState extends State<TimeTrackingHomePage> {
  bool isWorking = false;
  DateTime? startTime;
  Duration totalTimeWorkedToday = Duration.zero;
  Duration totalTimeWorkedWeek = Duration.zero;
  Duration totalTimeProcrastinatedToday = Duration.zero;
  Duration totalTimeProcrastinatedWeek = Duration.zero;
  int selectedDailyTarget = 1;
  int selectedWeeklyTarget = 5;
  List<ProcrastinationPeriod> procrastinationPeriodsToday = [];

  List<int> dailyTargets = List.generate(10, (index) => index + 1);
  List<int> weeklyTargets = List.generate(11, (index) => (index + 1) * 5);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalTimeWorkedToday =
          Duration(seconds: prefs.getInt('totalTimeWorkedToday') ?? 0);
      totalTimeWorkedWeek =
          Duration(seconds: prefs.getInt('totalTimeWorkedWeek') ?? 0);
      totalTimeProcrastinatedToday =
          Duration(seconds: prefs.getInt('totalTimeProcrastinatedToday') ?? 0);
      totalTimeProcrastinatedWeek =
          Duration(seconds: prefs.getInt('totalTimeProcrastinatedWeek') ?? 0);
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalTimeWorkedToday', totalTimeWorkedToday.inSeconds);
    await prefs.setInt('totalTimeWorkedWeek', totalTimeWorkedWeek.inSeconds);
    await prefs.setInt(
        'totalTimeProcrastinatedToday', totalTimeProcrastinatedToday.inSeconds);
    await prefs.setInt(
        'totalTimeProcrastinatedWeek', totalTimeProcrastinatedWeek.inSeconds);
  }

  void startWorking() {
    setState(() {
      isWorking = true;
      startTime = DateTime.now();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkingPage(
            onStopWorking: stopWorking,
            totalTimeWorkedToday: totalTimeWorkedToday,
            totalTimeWorkedWeek: totalTimeWorkedWeek,
            selectedDailyTarget: selectedDailyTarget,
            selectedWeeklyTarget: selectedWeeklyTarget,
          ),
        ),
      );
    });
  }

  void stopWorking() {
    if (startTime != null) {
      setState(() {
        isWorking = false;
        Duration workedTime = DateTime.now().difference(startTime!);
        totalTimeWorkedToday += workedTime;
        totalTimeWorkedWeek += workedTime;
        startTime = null;
        _saveData();
      });
    }
  }

  void startProcrastinating() {
    setState(() {
      procrastinationPeriodsToday
          .add(ProcrastinationPeriod(DateTime.now(), null));
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProcrastinationPage()),
    ).then((value) => stopProcrastinating());
  }

  void stopProcrastinating() {
    setState(() {
      if (procrastinationPeriodsToday.isNotEmpty) {
        ProcrastinationPeriod lastPeriod = procrastinationPeriodsToday.last;
        if (lastPeriod.endTime == null) {
          lastPeriod.endTime = DateTime.now();
          Duration procrastinatedTime =
              lastPeriod.endTime!.difference(lastPeriod.startTime);
          totalTimeProcrastinatedToday += procrastinatedTime;
          totalTimeProcrastinatedWeek += procrastinatedTime;
          _saveData();
        }
      }
    });
  }

  Future<void> resetTimers() async {
    setState(() {
      totalTimeWorkedToday = Duration.zero;
      totalTimeWorkedWeek = Duration.zero;
      totalTimeProcrastinatedToday = Duration.zero;
      totalTimeProcrastinatedWeek = Duration.zero;
      procrastinationPeriodsToday.clear();
    });
    await _saveData();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  BarChartGroupData generateGroupData(
    int x,
    double workedTime,
    double procrastinatedTime,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          fromY: 0,
          toY: workedTime,
          color: Colors.green,
          width: 10,
        ),
        BarChartRodData(
          fromY: workedTime,
          toY: workedTime + procrastinatedTime,
          color: Colors.red,
          width: 10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Duration dailyTargetDuration = Duration(hours: selectedDailyTarget);
    Duration weeklyTargetDuration = Duration(hours: selectedWeeklyTarget);
    Color backgroundColor = const Color.fromARGB(255, 85, 173, 228);
    Color appBarColor = const Color.fromARGB(255, 3, 74, 106);
    Color donoughtProgressColor = const Color.fromARGB(255, 3, 74, 106);
    Color donoughtBackgroundColor = const Color.fromARGB(255, 242, 226, 252);

    double dailyProgress = dailyTargetDuration.inSeconds > 0
        ? totalTimeWorkedToday.inSeconds / dailyTargetDuration.inSeconds
        : 0;
    double weeklyProgress = weeklyTargetDuration.inSeconds > 0
        ? totalTimeWorkedWeek.inSeconds / weeklyTargetDuration.inSeconds
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'mini time track',
          style: TextStyle(color: donoughtBackgroundColor),
        ),
        backgroundColor: appBarColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: backgroundColor,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Opacity(
                    opacity: isWorking ? 0.0 : 1.0,
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: selectedDailyTarget,
                            onChanged: (value) {
                              setState(() {
                                selectedDailyTarget = value!;
                              });
                            },
                            items: dailyTargets.map((int target) {
                              return DropdownMenuItem<int>(
                                value: target,
                                child: Text(
                                    '$target hour${target > 1 ? 's' : ''}'),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: "Today's Target",
                              labelStyle: TextStyle(color: appBarColor),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        appBarColor), // Set the underline color when enabled
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        appBarColor), // Set the underline color when focused
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        appBarColor), // Set the underline color when there is an error
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: selectedWeeklyTarget,
                            onChanged: (value) {
                              setState(() {
                                selectedWeeklyTarget = value!;
                              });
                            },
                            items: weeklyTargets.map((int target) {
                              return DropdownMenuItem<int>(
                                value: target,
                                child: Text('$target hours'),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Weekly Target',
                              labelStyle: TextStyle(color: appBarColor),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        appBarColor), // Set the underline color when enabled
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        appBarColor), // Set the underline color when focused
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        appBarColor), // Set the underline color when there is an error
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: startWorking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appBarColor,
                          foregroundColor: donoughtBackgroundColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Symbols.step,
                                color: donoughtBackgroundColor), // Example icon
                            const SizedBox(
                                width: 8), // Space between icon and text
                            Text(
                              "Start working",
                              style: TextStyle(
                                color: donoughtBackgroundColor,
                                fontSize: 18,
                                ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Or',
                        style: TextStyle(
                          fontSize: 16,
                          color: appBarColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ElevatedButton(
                        onPressed: startProcrastinating,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appBarColor,
                          foregroundColor: donoughtBackgroundColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Symbols.arrow_split,
                                color: donoughtBackgroundColor),
                            const SizedBox(
                                width: 8),
                            Text(
                              "No instead I'll\nprocrastinate",
                              style: TextStyle(
                                color: donoughtBackgroundColor,
                                fontSize: 18,
                                ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  if (!isWorking)
                    Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 160,
                                width: 160,
                                child: CircularProgressIndicator(
                                  value: dailyProgress,
                                  strokeWidth: 20,
                                  backgroundColor: donoughtBackgroundColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      donoughtProgressColor),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Today's work",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${totalTimeWorkedToday.inHours}h ${totalTimeWorkedToday.inMinutes.remainder(60)}m ${totalTimeWorkedToday.inSeconds.remainder(60)}s',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 160,
                                width: 160,
                                child: CircularProgressIndicator(
                                  value: weeklyProgress,
                                  strokeWidth: 20,
                                  backgroundColor: donoughtBackgroundColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      donoughtProgressColor),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Last 7 days',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${totalTimeWorkedWeek.inHours}h ${totalTimeWorkedWeek.inMinutes.remainder(60)}m ${totalTimeWorkedWeek.inSeconds.remainder(60)}s',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 50),
                            const Text(
                              'Procrastination today: ',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${totalTimeProcrastinatedToday.inHours}h ${totalTimeProcrastinatedToday.inMinutes.remainder(60)}m ${totalTimeProcrastinatedToday.inSeconds.remainder(60)}s',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black, // Set the default text color
                            ),
                            children: [
                              TextSpan(
                                text: 'Procrastination',
                                style:
                                    TextStyle(color: donoughtBackgroundColor),
                              ),
                              const TextSpan(text: ' / '),
                              TextSpan(
                                text: 'Work',
                                style: TextStyle(color: appBarColor),
                              ),
                            ],
                          ),
                        ),
                        TimeRatio(
                          data: TimeData(
                            totalTimeWorkedToday:
                                totalTimeWorkedToday.inSeconds,
                            totalTimeProcrastinatedToday:
                                totalTimeProcrastinatedToday.inSeconds,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: resetTimers,
                          child: const Text('Reset Timers',
                              style: TextStyle(
                                color: Color.fromARGB(255, 3, 74, 106),
                              )),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  text: 'by ',
                  style: TextStyle(color: appBarColor),
                  children: [
                    TextSpan(
                      text: 'maison-regneugneux.fr',
                      style: TextStyle(
                          color: donoughtBackgroundColor,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap =
                            () => _launchURL('https://maison-regneugneux.fr/'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProcrastinationPeriod {
  final DateTime startTime;
  DateTime? endTime;

  ProcrastinationPeriod(this.startTime, this.endTime);
}

class TimelinePainter extends CustomPainter {
  final List<ProcrastinationPeriod> procrastinationPeriods;

  TimelinePainter({required this.procrastinationPeriods});

  @override
  void paint(Canvas canvas, Size size) {
    final double lineY = size.height / 2;
    const double startX = 0;
    final double endX = size.width;

    final Paint linePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    final Paint procrastinationPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 6;

    canvas.drawLine(Offset(startX, lineY), Offset(endX, lineY), linePaint);

    final DateTime now = DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    const Duration dayDuration = Duration(days: 1);

    for (ProcrastinationPeriod period in procrastinationPeriods) {
      final double periodStartX = startX +
          (period.startTime.difference(startOfDay).inMilliseconds /
                  dayDuration.inMilliseconds) *
              size.width;
      final double periodEndX = period.endTime != null
          ? startX +
              (period.endTime!.difference(startOfDay).inMilliseconds /
                      dayDuration.inMilliseconds) *
                  size.width
          : endX;

      canvas.drawLine(Offset(periodStartX, lineY), Offset(periodEndX, lineY),
          procrastinationPaint);
    }
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) =>
      oldDelegate.procrastinationPeriods != procrastinationPeriods;
}
