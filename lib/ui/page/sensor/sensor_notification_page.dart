import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:ripe/service/background.dart';
import 'package:ripe/service/models/sensor.dart';
import 'package:ripe/service/sensor_service.dart';
import 'package:ripe/ui/component/branded.dart';

class SensorNotificationPage extends StatefulWidget {
  static const path = '/sensor/:id/notification';

  static String route(RegisteredSensor sensor) =>
      '/sensor/${sensor.id}/notification';

  final RegisteredSensor sensor;

  const SensorNotificationPage(this.sensor);

  @override
  State createState() => new _SensorNotificationPageState();
}

class _SensorNotificationPageState extends State<SensorNotificationPage> {
  late bool isEnabled;
  late NotificationConfig config;

  @override
  void initState() {
    super.initState();
    isEnabled = widget.sensor.notificationConfig != null;
    config = widget.sensor.notificationConfig ??
        NotificationConfig(
          battery: 10,
          moisture: RangeConfig(20, 40),
          temperature: RangeConfig(15, 30),
        );
  }

  void _onSubmit() {
    if (isEnabled) {
      config = SensorService.getInstance()
          .updateSensor(
              widget.sensor.copyWith(notificationConfig: Nullable(config)))
          .notificationConfig!;
    } else {
      SensorService.getInstance()
          .updateSensor(widget.sensor.copyWith(notificationConfig: null));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RipeAppBar(
        title: Text('${widget.sensor.name} Benachrichtigungen'),
      ),
      body: Container(
        //height: 200,
        child: ListView(
          children: [
            ListTile(
              title: const Text('Benachrichtigungen aktivieren'),
              trailing: Switch(
                value: isEnabled,
                onChanged: (value) => setState(() {
                  final notifications = FlutterLocalNotificationsPlugin();
                  if (Platform.isAndroid) {
                    notifications
                        .resolvePlatformSpecificImplementation<
                            AndroidFlutterLocalNotificationsPlugin>()
                        ?.requestNotificationsPermission();
                  }

                  isEnabled = value;
                }),
              ),
            ),
            if (isEnabled) ...[
              ListTile(
                title: Text(
                    'Temperatur außerhalb von ${config.temperature.min.toInt()}°C und ${config.temperature.max.toInt()}°C'),
                subtitle: RangeSlider(
                  min: 0.0,
                  max: 70.0,
                  values: RangeValues(
                    config.temperature.min,
                    config.temperature.max,
                  ),
                  //value: config.temperature.min,
                  divisions: 100,
                  onChanged: (newVal) => setState(() {
                    config.temperature.min = newVal.start;
                    config.temperature.max = newVal.end;
                  }),
                ),
              ),
              ListTile(
                title: Text(
                    'Feuchtigkeit außerhalb von ${config.moisture.min.toInt()}% und ${config.moisture.max.toInt()}%'),
                subtitle: RangeSlider(
                  min: 0.0,
                  max: 100.0,
                  values: RangeValues(
                    config.moisture.min,
                    config.moisture.max,
                  ),
                  divisions: 100,
                  onChanged: (newVal) => setState(() {
                    config.moisture.min = newVal.start;
                    config.moisture.max = newVal.end;
                  }),
                ),
              ),
              ListTile(
                title:
                    Text('Batterie niedriger als: ${config.battery.toInt()}%'),
                subtitle: Slider(
                  min: 0.0,
                  max: 100.0,
                  value: config.battery,
                  divisions: 100,
                  onChanged: (newVal) => setState(
                    () => config.battery = newVal,
                  ),
                ),
                onTap: () async {},
              ),
              ListTile(
                title: OutlinedButton(
                  onPressed: () {
                    final sensor = widget.sensor.copyWith(
                      notificationConfig: Nullable(config),
                    );
                    checkSensor(sensor);
                  },
                  child: const Text('Benachrichtigungen Testen'),
                ),
                subtitle: FutureBuilder(
                  future: getLastCheck(widget.sensor),
                  builder: (
                    context,
                    AsyncSnapshot<DateTime?> snapshot,
                  ) {
                    if (snapshot.data != null) {
                      final hr =
                          DateFormat('dd.MM.yyyy HH:mm').format(snapshot.data!);
                      return Text('Letzter check: $hr');
                    }
                    return const Text('Keine Benachrichtigung gesendet');
                  },
                ),
              )
            ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onSubmit,
        child: const Icon(Icons.check, color: Colors.white),
        hoverElevation: 0.0,
      ),
    );
  }
}
