import 'package:flutter/material.dart';

class WorkingPage extends StatefulWidget {
  final VoidCallback onStopWorking;
  final Duration totalTimeWorkedToday;
  final Duration totalTimeWorkedWeek;
  final int selectedDailyTarget;
  final int selectedWeeklyTarget;

  const WorkingPage({
    super.key,
    required this.onStopWorking,
    required this.totalTimeWorkedToday,
    required this.totalTimeWorkedWeek,
    required this.selectedDailyTarget,
    required this.selectedWeeklyTarget,
  });

  @override
  WorkingPageState createState() => WorkingPageState();
}

class WorkingPageState extends State<WorkingPage> {
  void _stopWorking() {
    widget.onStopWorking();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = const Color.fromARGB(255, 3, 74, 106);

    return Scaffold(
      body: Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Working! Woohoo!',
              style: TextStyle(
                fontSize: 24,
                fontFamily: "Roboto",  
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 167, 221, 255),
              ),
            ),
            const Text(
              "Now you can focus on your work...",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 167, 221, 255),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopWorking,
               style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
              child: const Text('Stop working for now',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:  Color.fromARGB(255, 3, 74, 106),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Add any other relevant widgets or information for the working page
          ],
        ),
      ),
    ),
    );
  }
}