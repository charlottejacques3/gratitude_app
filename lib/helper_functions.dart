//calculates days between to see whether the logs are from today, yesterday, etc.
int calculateDifference(DateTime date) {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day).difference(DateTime(date.year, date.month, date.day)).inDays;
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
  final hrs = time['hours'];

  //process hours
  if (hrs != null) {
    if (hrs == 0) {
      hrsMins = '12';
    } else if (hrs <= 12) {
      if (hrs < 10) {
        hrsMins += '0';
      }
      if (hrs == 12) {
        amPm = 'PM'; //if it's noon
      }
      hrsMins += hrs.toString();
    } else {
      if (hrs-12 < 10) {
        hrsMins += '0';
      }
      hrsMins += (hrs-12).toString();
      amPm = 'PM';
    }
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


//return datetime object of the next time this time will occur
DateTime nextTime(int hour, int minute) {
  DateTime now = DateTime.now();
  DateTime todayAtGivenTime = DateTime(now.year, now.month, now.day, hour, minute);
  if (now.isBefore(todayAtGivenTime)) {
    return todayAtGivenTime;
  } else {
    return todayAtGivenTime.add(const Duration(days: 1));
  }
}



//check if a time is valid from a string
bool validTime(String time) {
  //parse time string
  List<String> split = time.split(':');
  int hours = int.parse(split[0]);
  int minutes = int.parse(split[1]);

  return hours >= 1 && hours <= 12 && minutes >= 0 && minutes <= 60;
}

//check if one time is after the other
bool timeInOrder(String t1, String ampm1, String t2, String ampm2) {
  Map<String, int> t1_24 = amPmTo24(t1, ampm1);
  Map<String, int> t2_24 = amPmTo24(t2, ampm2);

  return t1_24['hours']! < t2_24['hours']! || 
        (t1_24['hours'] == t2_24['hours']! && t1_24['minutes']! < t2_24['minutes']!);
}