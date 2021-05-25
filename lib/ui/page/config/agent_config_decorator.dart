import 'package:flutter/material.dart';
import 'package:iftem/ui/component/colors.dart';
import 'package:iftem/ui/component/time_utils.dart';

/*
pub enum AgentConfigType {
    Switch(bool),                    // val
    DayTime(u64),                    // ms_of_day
    TimeSlider(i64, i64, i64, i64),  // lower_ms, upper_ms, val_ms, stepsize_ms
    IntSlider(i64, i64, i64),        // lower, upper, val
} */

enum DecoratorPosition { TRAILING, BELOW, TITLE }

abstract class AgentConfigDecorator extends StatefulWidget {
  @protected
  const AgentConfigDecorator({required Key key}) : super(key: key);

  factory AgentConfigDecorator.fromJson(
    GlobalKey<AgentConfigDecoratorState> key,
    Map<String, dynamic> json,
  ) {
    final jsonKey = json.keys.first;
    switch (jsonKey) {
      case SwitchDecorator.KEY:
        return SwitchDecorator(key, json[jsonKey] as bool);
      case DayTimeDecorator.KEY:
        return DayTimeDecorator(key, json[jsonKey] as int);
      case TimeSliderDecorator.KEY:
        final values = json[jsonKey] as List<dynamic>;
        return TimeSliderDecorator(
          key,
          values[0] as int,
          values[1] as int,
          values[2] as int,
          values[3] as int,
        );
      case IntSliderDecorator.KEY:
        final values = json[jsonKey] as List<dynamic>;
        return IntSliderDecorator(
          key,
          values[0] as int,
          values[1] as int,
          values[2] as int,
        );
    }
    return NotSupportedWidget(key, jsonKey);
  }

  DecoratorPosition get position;
}

abstract class AgentConfigDecoratorState<T extends AgentConfigDecorator>
    extends State<T> {
  Map<String, dynamic> getJsonValue();
}

/*
 * NotSupported
 */

class NotSupportedWidget extends AgentConfigDecorator {
  final String jsonKey;

  const NotSupportedWidget(Key key, this.jsonKey) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotSupportedState();

  @override
  DecoratorPosition get position => DecoratorPosition.TITLE;
}

class _NotSupportedState extends AgentConfigDecoratorState<NotSupportedWidget> {
  @override
  Map<String, dynamic> getJsonValue() => <String, dynamic>{};

  @override
  Widget build(BuildContext context) => Text(
      '${widget.jsonKey} noch nicht unterstützt - update die App!',
      style:
          Theme.of(context).textTheme.subtitle1!.copyWith(color: ERROR_COLOR));
}

/*
 * Switch
 */

class SwitchDecorator extends AgentConfigDecorator {
  static const String KEY = 'Switch';
  final bool val;

  const SwitchDecorator(Key key, this.val) : super(key: key);

  @override
  State createState() => _SwitchDecoratorState();

  @override
  DecoratorPosition get position => DecoratorPosition.TRAILING;
}

class _SwitchDecoratorState extends AgentConfigDecoratorState<SwitchDecorator> {
  late bool val;

  @override
  void initState() {
    super.initState();
    val = widget.val;
  }

  @override
  Map<String, dynamic> getJsonValue() {
    return <String, dynamic>{SwitchDecorator.KEY: val};
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: val,
      onChanged: (_) => setState(() => val = !val),
    );
  }
}

/*
 * DayTime
 */

class DayTimeDecorator extends AgentConfigDecorator {
  static const String KEY = 'DayTime';
  final int dayMs;

  const DayTimeDecorator(Key key, this.dayMs) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DayTimeDecoratorState();

  @override
  DecoratorPosition get position => DecoratorPosition.TRAILING;
}

class _DayTimeDecoratorState
    extends AgentConfigDecoratorState<DayTimeDecorator> {
  late int dayMs;

  @override
  void initState() {
    super.initState();
    dayMs = widget.dayMs;
  }

  @override
  Map<String, dynamic> getJsonValue() =>
      <String, dynamic>{DayTimeDecorator.KEY: dayMs};

  @override
  Widget build(BuildContext context) {
    final hour = dayMs ~/ HOUR_MS;
    final min = dayMs ~/ MIN_MS % 60;
    final formatted = '${pad(hour)}:${pad(min)} Uhr';
    final tod = TimeOfDay(hour: hour, minute: min);

    return OutlinedButton(
      onPressed: () async {
        final updated = await showTimePicker(
          context: context,
          initialTime: tod,
          builder: (context, child) {
            final data =
                MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true);
            return MediaQuery(
              data: data,
              child: child!,
            );
          },
        );
        if (updated != null) {
          setState(() {
            dayMs = updated.hour * HOUR_MS + updated.minute * MIN_MS;
          });
        }
      },
      child: Text(formatted),
    );
  }
}

/*
 * TimeSlider
 */

class TimeSliderDecorator extends AgentConfigDecorator {
  static const String KEY = 'TimeSlider';
  final int lower;
  final int upper;
  final int dayMs;
  final int stepCount;

  const TimeSliderDecorator(
      Key key, this.lower, this.upper, this.dayMs, this.stepCount)
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimeSliderState();

  @override
  DecoratorPosition get position => DecoratorPosition.BELOW;
}

class _TimeSliderState extends AgentConfigDecoratorState<TimeSliderDecorator> {
  late double lower;
  late double upper;
  late double dayMs;
  late int stepCount;

  @override
  void initState() {
    super.initState();
    lower = widget.lower.toDouble();
    upper = widget.upper.toDouble();
    dayMs = widget.dayMs.toDouble();
    stepCount = widget.stepCount;
  }

  @override
  Map<String, dynamic> getJsonValue() => <String, dynamic>{
        TimeSliderDecorator.KEY: <dynamic>[
          lower.toInt(),
          upper.toInt(),
          dayMs.toInt(),
          stepCount,
        ]
      };

  @override
  Widget build(BuildContext context) {
    final hour = dayMs ~/ HOUR_MS;
    final min = dayMs ~/ MIN_MS % 60;
    final sec = dayMs ~/ SEC_MS % 60;
    String formatted;
    if (upper <= HOUR_MS) {
      if (dayMs == upper) {
        formatted = '60:00';
      } else {
        formatted = '${pad(min)}:${pad(sec)}';
      }
    } else {
      formatted = '${pad(hour)}:${pad(min)}';
    }

    return new Container(
      child: Column(children: [
        Text(
          formatted,
          style: Theme.of(context).textTheme.button,
        ),
        Slider(
            min: lower.toDouble(),
            max: upper.toDouble(),
            value: dayMs,
            divisions: stepCount,
            onChanged: (newVal) => setState(() => dayMs = newVal))
      ]),
    );
  }
}

/*
 * IntSlider
 */

class IntSliderDecorator extends AgentConfigDecorator {
  static const String KEY = 'IntSlider';
  final int lower;
  final int upper;
  final int val;

  const IntSliderDecorator(Key key, this.lower, this.upper, this.val)
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _IntSliderRangeDecoratorState();

  @override
  DecoratorPosition get position => DecoratorPosition.BELOW;
}

class _IntSliderRangeDecoratorState
    extends AgentConfigDecoratorState<IntSliderDecorator> {
  late int lower;
  late int upper;
  late double val;

  @override
  void initState() {
    super.initState();
    lower = widget.lower;
    upper = widget.upper;
    val = widget.val.toDouble();
  }

  @override
  Map<String, dynamic> getJsonValue() => <String, dynamic>{
        IntSliderDecorator.KEY: <dynamic>[
          lower.toInt(),
          upper.toInt(),
          val.toInt(),
        ]
      };

  @override
  Widget build(BuildContext context) {
    final divisions = upper - lower;
    return new Container(
      child: Column(children: [
        Text(
          val.toStringAsFixed(0),
          style: Theme.of(context).textTheme.button,
        ),
        Slider(
            min: lower * 1.0,
            max: upper * 1.0,
            value: val * 1.0,
            divisions: divisions,
            onChanged: (newVal) => setState(() => val = newVal.toDouble()))
      ]),
    );
  }
}
