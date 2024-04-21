import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ripe/service/backend_service.dart';
import 'package:ripe/service/models/sensor.dart';
import 'package:ripe/service/sensor_service.dart';
import 'package:ripe/util/log.dart';
import 'package:workmanager/workmanager.dart';

const _notificationId = 0x80;

const PERIODIC_SYNC_TASK = 'periodicSync';

void _showNotification(String msg) {
  final notifications = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('notification_logo');
  const settings = InitializationSettings(android: androidSettings);
  notifications.initialize(settings);

  const androidDetails = AndroidNotificationDetails(
    'Warnungen',
    'Warnungen',
    channelDescription: 'Zeigt unregelmäßige Warnungen deiner Pflanzen an',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    ticker: 'ticker',
  );

  const details = NotificationDetails(android: androidDetails);
  notifications.show(
    _notificationId + msg.hashCode,
    'Deine Pflanze braucht Aufmerksamkeit',
    msg,
    details,
  );
  Log.debug('Displaying notification');
}

Future<void> checkSensor(RegisteredSensor registerSensor) async {
  Log.debug('Checking sensor ${registerSensor.name}');
  if (registerSensor.notificationConfig == null) {
    Log.info('No notification config for ${registerSensor.name}');
    return;
  }

  final now = DateTime.now();
  final config = registerSensor.notificationConfig!;
  final backendService = BackendService();
  final sensorService = SensorService.getInstance();
  await sensorService.init();

  try {
    final status = await backendService.getSensorStatus(registerSensor);
    final sensorData = status.sensorData;

    final timeDelta = sensorData.timestamp.difference(now).inHours;
    if (timeDelta >= 6) {
      _showNotification(
          '${registerSensor.name} hat lange keine Daten mehr gesendet');
    }
    if ((sensorData.battery ?? 0) < config.battery) {
      _showNotification('${registerSensor.name} hat wenig Akku');
    }
    if ((sensorData.moisture ?? 100) < config.moisture.min) {
      _showNotification('${registerSensor.name} hat zu wenig Feuchtigkeit');
    }
    if ((sensorData.moisture ?? 0) > config.moisture.max) {
      _showNotification('${registerSensor.name} hat zu viel Feuchtigkeit');
    }
    if ((sensorData.temperature ?? 100) > config.temperature.max) {
      _showNotification('${registerSensor.name} hat eine zu hohe Temperatur');
    }
    if ((sensorData.temperature ?? 100) < config.temperature.min) {
      _showNotification('${registerSensor.name} hat eine zu hohe Temperatur');
    }
  } catch (e) {
    Log.error('Failed to get sensor status for $registerSensor: $e');
    _showNotification(
        'Fehler beim Abrufen der Daten für ${registerSensor.name}');
  }
}

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    Log.debug('Running background task $task');
    if (task == PERIODIC_SYNC_TASK) {
      return Future.value(true);
    }

    // Check all sensors
    final sensorService = SensorService.getInstance();
    await Future.wait(sensorService.getSensors().map((e) => checkSensor(e)));

    return Future.value(true);
  });
}

Future<void> initBackgroundTasks() async {
  if (kIsWeb) {
    return;
  }
  Workmanager()
    ..initialize(
      _callbackDispatcher,
      isInDebugMode: !kReleaseMode,
    )
    ..registerPeriodicTask(
      PERIODIC_SYNC_TASK,
      PERIODIC_SYNC_TASK,
      frequency: const Duration(hours: 1),
    );
}
