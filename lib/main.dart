import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const TimeTrackingApp());
}

class TimeTrackingApp extends StatelessWidget {
  const TimeTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Tracking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  int selectedDailyTarget = 1;
  int selectedWeeklyTarget = 5;

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
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalTimeWorkedToday', totalTimeWorkedToday.inSeconds);
    await prefs.setInt('totalTimeWorkedWeek', totalTimeWorkedWeek.inSeconds);
  }

  void startWorking() {
    setState(() {
      isWorking = true;
      startTime = DateTime.now();
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

  Future<void> resetTimers() async {
    setState(() {
      totalTimeWorkedToday = Duration.zero;
      totalTimeWorkedWeek = Duration.zero;
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

  @override
  Widget build(BuildContext context) {
    Duration dailyTargetDuration = Duration(hours: selectedDailyTarget);
    Duration weeklyTargetDuration = Duration(hours: selectedWeeklyTarget);
    Color backgroundColor = isWorking
        ? const Color(0xFFD0F0C0)
        : const Color(
            0xFFFFE4E1);
    Color appBarColor = isWorking
        ? const Color(0xFF8FBC8F)
        : const Color(0xFFFFA07A);
    Color progressBarColor = isWorking
        ? const Color(0xFF32CD32)
        : const Color(0xFFFFA07A);
    Color progressBarBackgroundColor = isWorking
        ? const Color(0xFF98FB98)
        : const Color(0xFFFFDAB9);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracking'),
        backgroundColor: appBarColor,
      ),
      body: Container(
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
                              child:
                                  Text('$target hour${target > 1 ? 's' : ''}'),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Today Target',
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
                          decoration: const InputDecoration(
                            labelText: 'Weekly Target',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: isWorking ? null : startWorking,
                      child: const Text('Working'),
                    ),
                    ElevatedButton(
                      onPressed: isWorking ? stopWorking : null,
                      child: const Text('Not Working'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (!isWorking)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: dailyTargetDuration.inSeconds > 0
                                  ? totalTimeWorkedToday.inSeconds /
                                      dailyTargetDuration.inSeconds
                                  : 0,
                              minHeight: 20,
                              backgroundColor: progressBarBackgroundColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  progressBarColor),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text('$selectedDailyTarget hours'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: weeklyTargetDuration.inSeconds > 0
                                  ? totalTimeWorkedWeek.inSeconds /
                                      weeklyTargetDuration.inSeconds
                                  : 0,
                              minHeight: 20,
                              backgroundColor: progressBarBackgroundColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  progressBarColor),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text('$selectedWeeklyTarget hours'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          const Text(
                            'Total Time Worked Today: ',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.black54),
                          ),
                          Text(
                            '${totalTimeWorkedToday.inHours}:${totalTimeWorkedToday.inMinutes.remainder(60).toString().padLeft(2, '0')}:${totalTimeWorkedToday.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          const Text(
                            'Time Worked This Week: ',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.black54),
                          ),
                          Text(
                            '${totalTimeWorkedWeek.inHours}:${totalTimeWorkedWeek.inMinutes.remainder(60).toString().padLeft(2, '0')}:${totalTimeWorkedWeek.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: resetTimers,
                        child: const Text(
                          'Reset Timers',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: !isWorking,
              child: RichText(
                text: TextSpan(
                  text: 'made by ',
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'maison-regneugneux.fr',
                      style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap =
                            () => _launchURL('https://maison-regneugneux.fr/'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
