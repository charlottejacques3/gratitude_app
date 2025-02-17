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
  if (hours == 12 && amPm.compareTo('AM') == 0) {
    result['hours'] = 0; //if it's midnight
  } else if (amPm.compareTo('AM') == 0) {
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
  print('hours datatype ${hrs.runtimeType}');

  //process hours
  if (hrs != null) {
    if (hrs == 0) {
      hrsMins = '12';
    } else if (hrs <= 12) {
      if (hrs < 10) {
        hrsMins += '0';
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
    //better error handling?
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