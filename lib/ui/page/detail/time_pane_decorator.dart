import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/service/sensor_settings.dart';
import 'package:ripe/ui/component/colors.dart';
import 'package:ripe/ui/component/time_utils.dart';

import 'agent_decorator.dart';

class TimePaneDecorator extends BaseDecorator {
  static const KEY = 'TimePane';
  final int defaultTimeout;

  TimePaneDecorator(
    RegisteredSensor info,
    AgentDto agent,
    RefreshFn refreshFn,
    this.defaultTimeout,
  ) : super(info, agent, refreshFn);

  @override
  State<StatefulWidget> createState() => new _TimePaneDecoratorState();
}

class _TimePaneDecoratorState extends BaseDecoratorState<TimePaneDecorator> {
  late int forceSeconds;

  @override
  void initState() {
    super.initState();
    forceSeconds = widget.defaultTimeout;
  }

  /*
   * UI-Callbacks
   */

  void _onIncrease() {
    setState(() {
      forceSeconds += widget.defaultTimeout;
    });
  }

  void _onForce(bool on) {
    // TRANSFORM
    final payload = forceSeconds * (on ? 1 : -1);
    widget.sendAgentCmd(context, payload);

    setState(() {
      forceSeconds = widget.defaultTimeout;
    });
  }

  /*
   * Build
   */

  String _formatPayloadSecond() {
    final pad = (num n) => n < 10 ? '0$n' : '$n';
    if (forceSeconds % 60 == 0 || forceSeconds > 100) {
      return '${forceSeconds ~/ 60}:${pad(forceSeconds % 60)} Minuten';
    }
    return '$forceSeconds Sekunden';
  }

  String _buildEnableText() {
    String msg = '';
    if (!widget.isActive && !widget.isForcedOff) {
      msg = _formatPayloadSecond() + '\n';
    }
    return '${msg}einschalten';
  }

  String _buildDisableText() {
    String msg = '';
    if (widget.isActive && !widget.isForcedOn) {
      msg = _formatPayloadSecond() + '\n';
    }
    return '${msg}ausschalten';
  }

  Widget buildStatusText() {
    String appendix = ' ';
    Color color;

    switch (widget.state) {
      case AgentState.ERROR:
      case AgentState.STOPPED:
        color = Theme.of(context).errorColor;
        break;
      case AgentState.FORCED:
        color = Theme.of(context).colorScheme.secondary;
        break;
      default:
        color = Theme.of(context).primaryColor;
    }
    if (widget.isForcedOn || widget.isForcedOff) {
      appendix += toHR(widget.forceTime!);
    }
    // Get dart enum value, an strip prefix
    String status = widget.state.toString();
    status = status.substring(status.indexOf('.') + 1);

    return Row(children: [
      const Text('Status: '),
      Text(status, style: TextStyle(color: color)),
      Text(appendix),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            foregroundColor: Colors.white,
            label: 'Dauer ändern',
            autoClose: false,
            backgroundColor: ACCENT_COLOR,
            icon: Icons.more_time,
            onPressed: (_) => _onIncrease,
          ),
          SlidableAction(
            label: _buildEnableText(),
            backgroundColor: PRIMARY_COLOR,
            icon: Icons.settings_remote,
            onPressed: (_) => _onForce(true),
          ),
          SlidableAction(
            label: _buildDisableText(),
            backgroundColor: ERROR_COLOR,
            icon: Icons.power_settings_new,
            onPressed: (_) => _onForce(false),
          ),
        ],
      ),
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading: Switch(
                  onChanged: (_) =>
                      Slidable.of(context)?.openCurrentActionPane(),
                  value: widget.isActive),
              title: Text(widget.domainHR),
              trailing: Container(
                width: 68,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedOpacity(
                      opacity: isUpdating ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 750 ~/ 2),
                      child: const Icon(
                        Icons.sync,
                        size: 20.0,
                        color: BUTTON_COLOR_LIGHT,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.settings),
                      onPressed: () => widget.onSettings(context),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            ListTile(
              dense: true,
              title: Text(widget.rendered),
              subtitle: buildStatusText(),
            )
          ],
        ),
      ),
    );
  }
}
