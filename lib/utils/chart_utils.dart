// utils/chart_utils.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

BarChartGroupData generateGroupData(int x, double y1, double y2) {
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        fromY: 0,
        toY: y1 + y2,
        color: Colors.transparent,
        rodStackItems: [
          BarChartRodStackItem(0, y1, const Color.fromARGB(255, 3, 74, 106)),
          BarChartRodStackItem(y1, y1 + y2, const Color.fromARGB(255, 242, 226, 252)),
        ],
        width: 15,
      ),
    ],
  );
}
