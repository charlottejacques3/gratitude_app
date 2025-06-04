import 'package:intl/intl.dart';

//calculates days between to see whether the logs are from today, yesterday, etc.
int calculateDifference(DateTime date) {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day).difference(DateTime(date.year, date.month, date.day)).inDays;
}


//format date (today, yesterday, etc)
String formatDate(String isoDate) {
  DateTime date = DateTime.parse(isoDate);
  String formatted;
  int daysAgo = calculateDifference(date);

  if (daysAgo == 0) {
    formatted = 'Today';
  } else if (daysAgo == 1) {
    formatted = 'Yesterday';
  } else if (daysAgo <= 6){
    formatted = DateFormat('EEEE', 'en_US').format(date);
  } else if (daysAgo <= 364) {
    formatted = DateFormat('MMMMEEEEd', 'en_US').format(date);
  } else {
    formatted = DateFormat.yMMMMEEEEd().format(date);
  }

  return formatted;
}

String formatDateShort(String isoDate) {
  DateTime date = DateTime.parse(isoDate);
  String formatted;
  int daysAgo = calculateDifference(date);

  if (daysAgo == 0) {
    formatted = 'Today';
  } else if (daysAgo == 1) {
    formatted = 'Yesterday';
  } else if (daysAgo <= 6){
    formatted = DateFormat('EEEE', 'en_US').format(date);
  } else if (daysAgo <= 364) {
    formatted = DateFormat('MMMMEEEEd', 'en_US').format(date);
  } else {
    formatted = DateFormat.yMMMMEEEEd().format(date);
  }

  return formatted;
}


//am/pm to 24 hours
Map<String, int> amPmTo24(String time, String amPm) {
  Map<String, int> result = {};

  //parse time string
  List<String> split = time.split(':');
  int hours = int.parse(split[0]);
  int minutes = int.parse(split[1]);

  //add to map
  if (hours == 12 && amPm.compareTo('AM') == 0) { //if it's midnight
    result['hours'] = 0;
  } else if (amPm.compareTo('AM') == 0 || hours == 12) { //am or noon
    result['hours'] = hours;
  } else {
    result['hours'] = hours + 12;
  }
  result['minutes'] = minutes;

  return result;
}


//24 hours to am/pm
Map<String, String> twenty4ToAmPm(Map<dynamic, dynamic> time) {
  Map<String, String> result = {};
  String hrsMins = '';
  String amPm = 'AM';
  var hrs = time['hours'];

  //process hours
  if (hrs != null) {
    if (hrs >= 12) {
      amPm = 'PM';
    } 
    if (hrs > 12) {
      hrs -= 12;
    } else if (hrs == 0) {
      hrs = 12;
    }
    hrsMins += hrs.toString();
  } else {
    print('error: hours was null');
  }
  hrsMins += ':';
  //process minutes
  final mins = time['minutes'];
  if (mins != null) {
    if (mins < 10) {
      hrsMins += '0';
    }
    hrsMins += mins.toString();
  } else {
    print('error: minutes was null');
  }

  result['hrs_mins'] = hrsMins;
  result['am_pm'] = amPm;
  return result;
}