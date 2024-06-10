// widgets/time_ratio.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:time_tracking_app/models/time_data.dart';
import 'package:time_tracking_app/utils/chart_utils.dart';

class TimeRatio extends StatelessWidget {
  final TimeData data;

  const TimeRatio({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 250, // Adjust the height as needed
        width: 10, // Adjust the width as needed
        child:
          Transform(
          alignment: Alignment.center,
          transform: Matrix4.translationValues(0, -85, 0) * Matrix4.rotationZ(-pi / 2),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceBetween,
              maxY: data.totalTimeWorkedToday.toDouble() + data.totalTimeProcrastinatedToday.toDouble(),
              barTouchData: BarTouchData(enabled: false),
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                generateGroupData(
                  0,
                  data.totalTimeWorkedToday.toDouble(),
                  data.totalTimeProcrastinatedToday.toDouble(),
                ),
              ],
            ),
          ),
        ),
        ),
      );
  }
}