import 'package:flutter/foundation.dart';

class _CallerTrace {
  final StackTrace _trace;
  late String fileName;
  late int lineNumber;

  _CallerTrace(this._trace) {
    fileName = 'unknown';
    lineNumber = 0;
    try {
      // Get caller line
      String traceString = _trace.toString().split('\n')[1];

      // Search the 'file_name.dart:5:12' with regex
      final indexOfFileName = traceString.indexOf(RegExp(r'[A-Za-z_]+.dart'));
      if (indexOfFileName == -1) {
        traceString = _trace.toString().split('\n')[2];
        final indexOfFileName = traceString.indexOf(RegExp(r'[A-Za-z_]+.dart'));
        if (indexOfFileName == -1) {
          fileName = 'unknown';
          lineNumber = 0;
          return;
        }
      }

      String fileInfo =
          traceString.substring(indexOfFileName).replaceAll(' ', ':');
      if (fileInfo.endsWith(')')) {
        fileInfo = fileInfo.substring(0, fileInfo.length - 1);
      }

      final tokens = fileInfo.split(':');
      fileName = tokens[0];
      lineNumber = int.parse(tokens[1]);
    } catch (e) {
      print('Failed creating trace $e');
    }
  }

  @override
  String toString() => '$fileName:$lineNumber';
}

enum LogLevel {
  DEBUG,
  INFO,
  WARN,
  ERROR,
}

// ignore: avoid_classes_with_only_static_members
class Log {
  static LogLevel level = kReleaseMode ? LogLevel.INFO : LogLevel.DEBUG;

  static void debug(String msg) {
    if (level.index > LogLevel.DEBUG.index) {
      return;
    }
    final trace = new _CallerTrace(StackTrace.current);
    final time = new DateTime.now().toString().substring(0, 23);
    final formatted = '$time \x1B[34mDEBUG\x1B[0m \x1B[1m$msg\x1B[0m $trace';
    print(formatted);
  }

  static void info(String msg) {
    if (level.index > LogLevel.INFO.index) {
      return;
    }
    final trace = new _CallerTrace(StackTrace.current);
    final time = new DateTime.now().toString().substring(0, 23);
    final formatted = '$time \x1B[32mINFO\x1B[0m \x1B[1m$msg\x1B[0m $trace';
    print(formatted);
  }

  static void warn(String msg) {
    if (level.index > LogLevel.WARN.index) {
      return;
    }
    final trace = new _CallerTrace(StackTrace.current);
    final time = new DateTime.now().toString().substring(0, 23);
    final formatted = '$time \x1B[33mWARN\x1B[0m \x1B[1m$msg\x1B[0m $trace';
    print(formatted);
  }

  static void error(String msg) {
    if (level.index > LogLevel.WARN.index) {
      return;
    }
    final trace = new _CallerTrace(StackTrace.current);
    final time = new DateTime.now().toString().substring(0, 23);
    final formatted = '$time \x1B[31mERROR\x1B[0m \x1B[1m$msg\x1B[0m $trace';
    print(formatted);
  }
}
