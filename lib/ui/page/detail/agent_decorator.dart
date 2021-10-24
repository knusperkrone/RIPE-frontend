import 'package:flutter/material.dart';
import 'package:ripe/service/backend_service.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/service/sensor_settings.dart';
import 'package:ripe/ui/component/branded.dart';
import 'package:ripe/ui/component/colors.dart';
import 'package:ripe/ui/page/config/agent_config_page.dart';
import 'package:ripe/ui/page/detail/slider_decorator.dart';
import 'package:ripe/ui/page/detail/time_pane_decorator.dart';

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
      case TimePaneDecorator.KEY:
        final val = decoratorMap[uiKey] as int;
        return TimePaneDecorator(info, agent, refreshCallback, val);
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
              .subtitle1!
              .copyWith(color: ERROR_COLOR),
        ),
      ),
    );
  }
}

abstract class BaseDecoratorState<T extends BaseDecorator> extends State<T> {
  bool isUpdating = false;

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._agent.ui != widget._agent.ui) {
      setState(() => isUpdating = true);
      Future.delayed(const Duration(milliseconds: 750), () {
        setState(() => isUpdating = false);
      });
    }
  }
}

abstract class BaseDecorator extends StatefulWidget {
  final _backendService = new BackendService();
  final RefreshFn _refreshCallback;
  final RegisteredSensor _sensor;
  final AgentDto _agent;

  BaseDecorator(this._sensor, this._agent, this._refreshCallback);

  Future<void> sendAgentCmd(BuildContext context, int payload) async {
    if (!await _backendService.sendAgentCmd(
      id: _sensor.id,
      key: _sensor.key,
      domain: domain,
      payload: payload,
    )) {
      final snackbar = RipeSnackbar(
        context,
        label: 'Befehl konnte nicht gesendet werden',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future<void> onSettings(BuildContext context) async {
    final settings = await Navigator.push<Map<String, dynamic>>(context,
        MaterialPageRoute(builder: (_) {
      final configFut = _backendService.getAgentConfig(
        id: _sensor.id,
        key: _sensor.key,
        domain: domain,
      );
      return AgentConfigPage(domain, configFut);
    }));

    if (settings != null) {
      final success = await _backendService.setAgentConfig(
        id: _sensor.id,
        key: _sensor.key,
        domain: domain,
        settings: settings,
      );

      if (success) {
        _refreshCallback();
      } else {
        final snackbar = RipeSnackbar(
          context,
          label: 'Konfiguration konnte nicht gesendet werden',
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    }
  }

  String get domainHR =>
      _agent.domain.substring(_agent.domain.indexOf('_') + 1);

  String get domain => _agent.domain;

  String get rendered => _agent.ui.rendered;

  bool get isActive => _agent.ui.state.isActive;

  bool get isForcedOn => _agent.ui.state.isForcedOn;

  bool get isForcedOff => _agent.ui.state.isForcedOff;

  DateTime? get forceTime => _agent.ui.state.time;

  AgentState get state => _agent.ui.state.state;
}
