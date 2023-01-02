import 'package:flutter/material.dart';
import 'package:ripe/service/backend_service.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/service/sensor_listener_service.dart';
import 'package:ripe/service/sensor_setting_service.dart';
import 'package:ripe/ui/component/branded.dart';

class SensorLogPage extends StatefulWidget {
  final SensorDto sensorDto;
  final RegisteredSensor sensor;

  const SensorLogPage(this.sensor, this.sensorDto);

  @override
  State createState() => _SensorLogState();
}

class _SensorLogState extends State<SensorLogPage> {
  final _backendService = new BackendService();
  SensorListenerService? _listenerService;
  List<String>? logs;

  @override
  void initState() {
    super.initState();
    _refreshLogs();
    _initMqtt();
  }

  @override
  void dispose() {
    _listenerService?.dispose();
    super.dispose();
  }

  void _initMqtt() {
    if (widget.sensorDto.broker.tcp != null && _listenerService != null) {
      _listenerService = new SensorListenerService(widget.sensorDto.broker);
      _listenerService!.connect(onDisconnect: onMqttDisconnected).then((_) {
        _listenerService!.listenSensorLogs(
          widget.sensor.id,
          widget.sensor.key,
          () => Future.delayed(const Duration(milliseconds: 500), _refreshLogs),
        );
      });
    }
  }

  void onMqttDisconnected() {
    _listenerService!.reconnect();
  }

  Future<void> _refreshLogs() async {
    _backendService
        .getSensorLogs(widget.sensor.id, widget.sensor.key)
        .then((value) {
      if (value == null) {
        final snackbar = RipeSnackbar(
          context,
          label: 'Logs konnten nicht geladen werden',
          duration: const Duration(seconds: 60),
          action: SnackBarAction(
            label: 'Ok',
            onPressed: () => Navigator.pop(context),
          ),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        return;
      } else {
        setState(() => logs = value);
      }
    });
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
