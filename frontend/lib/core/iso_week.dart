/// Returns the ISO-8601 week string for [date], e.g. `2026-W17`.
///
/// Matches the backend's `WeeklySchedule.isoWeek` column format. Weeks start
/// on Monday; week 1 contains the first Thursday of the ISO year (which can
/// belong to the previous calendar year).
String isoWeekString(DateTime date) {
  // Find Thursday of this ISO week; its calendar year is the ISO year.
  final thursday = date.add(Duration(days: 3 - ((date.weekday + 6) % 7)));
  final firstThursday = DateTime(thursday.year, 1, 4);
  final firstThursdayWeekStart =
      firstThursday.subtract(Duration(days: (firstThursday.weekday + 6) % 7));
  final weekNumber =
      ((thursday.difference(firstThursdayWeekStart).inDays) / 7).floor() + 1;
  return '${thursday.year}-W${weekNumber.toString().padLeft(2, '0')}';
}
