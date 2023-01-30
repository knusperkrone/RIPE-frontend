import 'package:flutter/material.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/service/sensor_setting_service.dart';

import 'base_decorator.dart';

class SliderDecorator extends BaseDecorator {
  static const KEY = 'Slider';
  final List<double> values;

  SliderDecorator(
    RegisteredSensor info,
    AgentDto agent,
    RefreshFn refreshFn,
    this.values,
  )   : assert(values.length == 3),
        super(info, agent, refreshFn);

  @override
  State<StatefulWidget> createState() => new _SliderDecoratorState();
}

class _SliderDecoratorState extends BaseDecoratorState<SliderDecorator> {
  late double _val;

  @override
  void initState() {
    super.initState();
    _val = widget.values[2];
  }

  /*
   * UI Callbacks
   */

  void _onChanged(double newVal) {
    final payload = (newVal * 1000).round();
    widget.sendAgentCmd(context, payload);
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.domainHR),
            subtitle: Text(widget.rendered),
            trailing: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => widget.onSettings(context),
            ),
          ),
          const Divider(),
          Slider(
            min: widget.values[0],
            max: widget.values[1],
            value: _val,
            onChangeEnd: _onChanged,
            onChanged: (newVal) => setState(() => _val = newVal),
          ),
        ],
      ),
    );
  }
}
