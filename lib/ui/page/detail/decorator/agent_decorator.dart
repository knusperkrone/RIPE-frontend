import 'package:flutter/material.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/service/sensor_setting_service.dart';
import 'package:ripe/ui/component/colors.dart';

import 'slider_decorator.dart';
import 'timed_decorator.dart';

typedef RefreshFn = Future<void> Function();

class AgentDecorator extends StatelessWidget {
  final RegisteredSensor info;
  final AgentDto agent;
  final RefreshFn refreshCallback;

  const AgentDecorator({
    required this.info,
    required this.agent,
    required this.refreshCallback,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoratorMap = agent.ui.decorator.payload;
    assert(decoratorMap.keys.length == 1);

    final uiKey = decoratorMap.keys.first;
    switch (decoratorMap.keys.first) {
      case TimedDecorator.KEY:
        final val = decoratorMap[uiKey] as int;
        return TimedDecorator(info, agent, refreshCallback, val);
      case SliderDecorator.KEY:
        final val = decoratorMap[uiKey] as List<dynamic>;
        return SliderDecorator(info, agent, refreshCallback, val.cast());
    }
    // Not supported
    return Card(
      child: ListTile(
        title: Text(
          '$uiKey ist noch nicht unterstützt - update die App!',
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: ERROR_COLOR),
        ),
      ),
    );
  }
}
