//calculates days between to see whether the logs are from today, yesterday, etc.
int calculateDifference(DateTime date) {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day).difference(DateTime(date.year, date.month, date.day)).inDays;
}