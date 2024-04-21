import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ripe/service/backend_service.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/service/models/sensor.dart';
import 'package:ripe/ui/component/branded.dart';
import 'package:ripe/ui/page/sensor/agent/agent_config_page.dart';

typedef RefreshFn = Future<void> Function();

abstract class BaseDecoratorState<T extends BaseDecorator> extends State<T> {
  bool isUpdating = false;

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._agent.ui != widget._agent.ui) {
      setState(() => isUpdating = true);
      Future.delayed(const Duration(milliseconds: 750), () {
        if (mounted) {
          setState(() => isUpdating = false);
        }
      });
    }
  }
}

abstract class BaseDecorator extends StatefulWidget {
  final _backendService = new BackendService();
  final RegisteredSensor _sensor;
  final AgentDto _agent;

  BaseDecorator(this._sensor, this._agent);

  Future<void> sendAgentCmd(BuildContext context, int payload) async {
    try {
      await _backendService.sendAgentCmd(
        id: _sensor.id,
        key: _sensor.key,
        domain: domain,
        payload: payload,
      );
    } catch (e) {
      final snackbar = RipeSnackbar(
        context,
        label: 'Befehl konnte nicht gesendet werden',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future<void> onConfig(BuildContext context) async {
    final settings = await GoRouter.of(context)
        .push<bool>(AgentConfigPage.route(_sensor, domain));
    if (settings == false) {
      final snackbar = RipeSnackbar(
        context,
        label: 'Konfiguration konnte nicht gesendet werden',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
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
