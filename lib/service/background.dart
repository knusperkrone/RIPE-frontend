import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ripe/service/backend_service.dart';
import 'package:ripe/service/models/sensor.dart';
import 'package:ripe/service/sensor_service.dart';
import 'package:ripe/util/log.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    channelDescription: 'Zeige Mängel deiner Pflanzen an',
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

Future<DateTime?> getLastCheck(RegisteredSensor sensor) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  final lastCheck = sharedPrefs.getString('SENSOR_LAST_CHECK_${sensor.id}');
  if (lastCheck == null) {
    return null;
  }
  return DateTime.parse(lastCheck);
}

Future<void> setLastCheck(RegisteredSensor sensor, DateTime time) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  sharedPrefs.setString(
      'SENSOR_LAST_CHECK_${sensor.id}', time.toIso8601String());
}

Future<bool> checkSensor(RegisteredSensor registerSensor) async {
  Log.debug('Checking sensor ${registerSensor.name}');
  if (registerSensor.notificationConfig == null) {
    Log.info('No notification config for ${registerSensor.name}');
    return false;
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
  setLastCheck(registerSensor, now);
  return true;
}

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Log.debug("Startup background task");
  Workmanager().executeTask((task, inputData) async {
    Log.debug('Running background task $task');
    // Check all sensors
    try {
      final sensorService = SensorService.getInstance();
      await sensorService.init();

      await Future.wait(sensorService.getSensors().map((e) => checkSensor(e)));
    } catch (e) {
      Log.error('Failed to run background task: $e');
      return false;
    }

    Log.info('Successfully ran background task $task');
    return true;
  });
}

Future<void> initBackgroundTasks() async {
  Log.debug("Setting up background tasks");
  Workmanager()
    ..initialize(
      _callbackDispatcher,
      isInDebugMode: true,
    )
    ..registerPeriodicTask(
      PERIODIC_SYNC_TASK,
      PERIODIC_SYNC_TASK,
      frequency: const Duration(hours: 1),
    );
}
