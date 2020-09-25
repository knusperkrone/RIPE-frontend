class TimeUtils {
  static String pad(int num) => num < 10 ? '0$num' : '$num';

  static String fullDateTimeShort(DateTime time) {
    if (time == null) {
      return '∞';
    }
    return '${time.day} ${getMonthHR(time.month)} ${pad(time.hour)}:${pad(time.minute)}';
  }

  static String toHourHR(DateTime time) {
    if (time == null) {
      return '∞';
    }
    return '${pad(time.hour)}:${pad(time.minute)}:${pad(time.second)}';
  }

  static String toHR(DateTime time) {
    if (time == null) {
      return '∞';
    }
    return '${time.year}-${pad(time.month)}-${pad(time.day)} ${pad(time.hour)}:${pad(time.minute)}:${pad(time.second)}';
  }

  static String getMonthHR(int month) {
    switch (month) {
      case 0:
        return 'Januar';
      case 1:
        return 'Februar';
      case 2:
        return 'März';
      case 3:
        return 'April';
      case 4:
        return 'Mai';
      case 5:
        return 'Juni';
      case 6:
        return 'Juli';
      case 7:
        return 'August';
      case 8:
        return 'September';
      case 9:
        return 'Oktober';
      case 10:
        return 'November';
      case 11:
        return 'Dezember';
    }
    return 'INVALID';
  }
}
