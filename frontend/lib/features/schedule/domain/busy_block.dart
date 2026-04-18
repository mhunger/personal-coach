import 'package:flutter/material.dart';

class BusyBlock {
  final int day; // DateTime.weekday convention: 1 = Monday … 7 = Sunday.
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String label;

  const BusyBlock({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.label,
  });
}
