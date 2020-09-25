import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iftem/service/backend_service.de.dart';
import 'package:iftem/service/models/dto.dart';
import 'package:iftem/service/sensor_settings.dart';
import 'package:iftem/ui/component/colors.dart';
import 'package:iftem/ui/component/time_utils.dart';

class AgentDecorator extends StatelessWidget {
  static const _TIME_PANE_KEY = 'TimePane';
  static const _SLIDER_KEY = 'Slider';

  final RegisteredSensor info;
  final AgentDto agent;

  const AgentDecorator(this.info, this.agent) : assert(agent != null);

  @override
  Widget build(BuildContext context) {
    Widget widget;
    final decoratorMap = agent.ui.decorator.payload;
    if (decoratorMap.containsKey(_TIME_PANE_KEY)) {
      widget =
          _TimePaneDecorator(info, agent, decoratorMap[_TIME_PANE_KEY] as int);
    } else if (decoratorMap.containsKey(_SLIDER_KEY)) {
      widget = _SliderDecorator();
    } else {
      widget = Card(
        child: ListTile(
          title: Text(
            'Nicht unterstützt - update die App!',
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(color: ERROR_COLOR),
          ),
        ),
      );
    }
    return widget;
  }
}

class _TimePaneDecorator extends StatefulWidget {
  final RegisteredSensor info;
  final AgentDto agent;
  final int defaultTimeout;

  const _TimePaneDecorator(this.info, this.agent, this.defaultTimeout)
      : assert(agent != null && defaultTimeout != null);

  @override
  State<StatefulWidget> createState() => new _TimePaneDecoratorState();
}

class _TimePaneDecoratorState extends State<_TimePaneDecorator> {
  final _backendService = new BackendService();
  final _slideKey = new GlobalKey<SlidableState>();

  int forceSeconds;

  @override
  void initState() {
    super.initState();
    forceSeconds = widget.defaultTimeout;
  }

  /*
   * UI-Callbacks
   */

  void _onSettings() {
    // TODO(knukro): Settings page
  }

  void _onIncrease() {
    setState(() {
      forceSeconds += widget.defaultTimeout;
    });
  }

  void _onForce() {
    final state = widget.agent.ui.state;
    final active = state.isActive || state.isForced.isNotEmpty;

    _backendService.forceAgent(
      id: widget.info.id,
      key: widget.info.key,
      domain: widget.agent.domain,
      active: !active,
      secs: forceSeconds,
    );
    setState(() {
      forceSeconds = widget.defaultTimeout;
    });
  }

  /*
   * Build
   */

  String buildForceText() {
    String msg;
    final state = widget.agent.ui.state;
    if (state.isForced.isEmpty) {
      if (forceSeconds % 60 == 0 || forceSeconds > 360) {
        msg = '${forceSeconds ~/ 60} Minuten';
      } else {
        msg = '$forceSeconds Sekunden';
      }
      msg += '\n';
    } else {
      msg = '';
    }

    if (state.isActive || state.isForced.isNotEmpty) {
      msg += 'aus';
    } else {
      msg += 'ein';
    }
    return '${msg}schalten';
  }

  Widget buildStatusText() {
    String status;
    String appendix = ' ';
    Color color = Theme.of(context).primaryColor;

    final agentState = widget.agent.ui.state;
    if (agentState.isForced.isNotEmpty) {
      final forcedState = agentState.isForced.value;
      if (forcedState.item1) {
        status = 'Laufend';
      } else {
        status = 'Pausiert';
        color = Theme.of(context).errorColor;
      }
      appendix += TimeUtils.toHR(forcedState.item2);
    } else if (agentState.isActive) {
      status = 'Aktiv';
    } else {
      status = 'Inaktiv';
    }

    return Row(children: [
      const Text(
        'Status: ',
        style: TextStyle(color: Colors.black26),
      ),
      Text(status, style: TextStyle(color: color)),
      Text(appendix),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.agent.ui.state;
    return Slidable(
      key: _slideKey,
      actionPane: const SlidableDrawerActionPane(),
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading: Switch(
                  onChanged: (_) => _slideKey.currentState.open(),
                  value: state.isActive || state.isForced.isNotEmpty),
              title: Text(widget.agent.domain),
              trailing: IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.black26,
                ),
                onPressed: _onSettings,
              ),
            ),
            const Divider(),
            ListTile(
              dense: true,
              title: Text(widget.agent.ui.rendered),
              subtitle: buildStatusText(),
            )
          ],
        ),
      ),
      actions: [
        Card(
          child: IconSlideAction(
            caption: 'Zeit erhöhen',
            icon: Icons.add,
            color: Theme.of(context).errorColor,
            onTap: _onIncrease,
            closeOnTap: false,
          ),
        ),
        Card(
          child: IconSlideAction(
            caption: buildForceText(),
            icon: Icons.settings,
            foregroundColor: Colors.white,
            color: Theme.of(context).primaryColor,
            onTap: _onForce,
            closeOnTap: true,
          ),
        ),
      ],
    );
  }
}

class _SliderDecorator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SliderDecoratorState();
}

class _SliderDecoratorState extends State<_TimePaneDecorator> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
