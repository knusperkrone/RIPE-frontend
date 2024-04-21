import 'package:flutter/material.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/service/models/sensor.dart';
import 'package:ripe/ui/component/colors.dart';
import 'package:ripe/ui/component/time_utils.dart';
import 'package:ripe/ui/page/dialog/timed_decorator_dialog.dart';

import 'base_decorator.dart';

class TimedDecorator extends BaseDecorator {
  static const KEY = 'TimePane';
  final int defaultTimeout;

  TimedDecorator(RegisteredSensor info, AgentDto agent, this.defaultTimeout)
      : super(info, agent);

  @override
  State<StatefulWidget> createState() => new _TimeDecoratorState();
}

class _TimeDecoratorState extends BaseDecoratorState<TimedDecorator> {
  /*
   * UI-Callbacks
   */

  void _onForce(bool on, int forceSeconds) {
    final payload = forceSeconds * (on ? 1 : -1);
    widget.sendAgentCmd(context, payload);
  }

  /*
   * Build
   */

  Widget buildStatusText() {
    String appendix = ' ';
    Color color;

    switch (widget.state) {
      case AgentState.ERROR:
      case AgentState.STOPPED:
        color = Theme.of(context).colorScheme.error;
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

  Future<void> _showDialog(BuildContext context) async {
    final result = await showDialog<TimePaneDecoratorDialogResult?>(
      context: context,
      builder: (context) => TimePaneDecoratorDialog(
          domainHR: widget.domainHR, defaultTimeout: widget.defaultTimeout),
    );

    if (result != null) {
      _onForce(result.isEnabled, result.forceSeconds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showDialog(context),
        child: Column(
          children: [
            ListTile(
              leading: Switch(
                onChanged: (_) => _showDialog(context),
                value: widget.isActive,
              ),
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
                      onPressed: () => widget.onConfig(context),
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
