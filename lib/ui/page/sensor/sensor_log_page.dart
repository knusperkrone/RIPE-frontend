import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:ripe/service/backend_service.dart';
import 'package:ripe/service/models/sensor.dart';
import 'package:ripe/service/sensor_listener_service.dart';
import 'package:ripe/ui/component/branded.dart';
import 'package:ripe/ui/page/sensor/sensor_overview_page.dart';
import 'package:ripe/ui/page/util/mqtt_state.dart';

class SensorLogPage extends StatefulWidget {
  static const String path = '/sensor/:id/log';

  static String route(RegisteredSensor sensor) => '/sensor/${sensor.id}/log';

  final RegisteredSensor sensor;

  const SensorLogPage(this.sensor);

  @override
  State createState() => _SensorLogState();
}

class _SensorLogState extends MqttState<SensorLogPage> {
  final _backendService = new BackendService();

  List<String>? logs;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
    _backendService.getSensorStatus(widget.sensor).then((value) {
      listenerService = new SensorListenerService(widget.sensor, value.broker);
      connectToBroker();
    });

    // refresh on mqtt
  }

  @override
  void connectToBroker() {
    listenerService!.connect(callback: (state) {
      if (state == MqttConnectionState.disconnected) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Verbindung zum Server verloren'),
          duration: Duration(seconds: 5),
        ));
      }
    });
    listenerService!.listenSensorLogs((_) => _fetchLogs());
  }

  Future<void> _fetchLogs() async {
    final updatedLogs = await _backendService.getSensorLogs(
        widget.sensor.id, widget.sensor.key);
    if (updatedLogs == null) {
      final snackbar = RipeSnackbar(
        context,
        label: 'Logs konnten nicht geladen werden',
        duration: const Duration(seconds: 60),
        action: SnackBarAction(
            label: 'Ok',
            onPressed: () =>
                GoRouter.of(context).pushReplacement(SensorOverviewPage.path)),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
      return;
    } else {
      setState(() => logs = updatedLogs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RipeAppBar(
        title: const Text('Sensor Logs'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: logs?.length ?? 0,
          itemBuilder: (context, i) {
            return Text(
              logs![i],
              style: const TextStyle(fontSize: 13),
            );
          },
        ),
      ),
    );
  }
}
