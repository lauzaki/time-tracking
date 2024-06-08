import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Well done! You are currently working!',
              style: TextStyle(
                fontSize: 24,
                fontFamily: "Roboto",  
                fontWeight: FontWeight.w100,
                color: Color.fromARGB(255, 167, 221, 255),
              ),
            ),
            const Text(
              "Now you can stop looking at this phone...",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 167, 221, 255),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopWorking,
              child: const Text('Stop working for now',
                style: TextStyle(
                  fontSize: 16,
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
    );
  }
}