import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ripe/service/models/sensor.dart';
import 'package:ripe/service/settings/base_pref_service.dart';

import '../constants.dart';
import '../util/log.dart';
import 'settings/sensor_service_mobile.dart';
import 'settings/sensor_service_web.dart';

abstract class SensorService extends BasePrefService {
  @protected
  late Map<int, RegisteredSensor> sensors;

  /*
   * Singleton logic
   */

  @protected
  static final SensorService _instance =
      kIsWeb ? new SensorServiceWeb() : new SensorServiceMobile();

  static SensorService getInstance() => _instance;

  /*
   * Contract
   */

  @mustCallSuper
  @override
  Future<void> init() async {
    await super.init();
    sensors = await cacheSensors();
  }

  RegisteredSensor? getById(String id) => sensors[int.tryParse(id)];

  Future<RegisteredSensor?> addSensor(
      int id, String key, String name, String? imagePath);

  void removeSensor(int id);

  Future<RegisteredSensor> changeImage(int id, String imagePath);

  String get placeholderPath;

  Color get placeholderThumbnailColor;

  List<RegisteredSensor> getSensors() {
    Log.debug('Loaded ${sensors.length} sensors');
    return List.of(sensors.values); // clone list
  }

  RegisteredSensor updateSensor(RegisteredSensor sensor) {
    sensors[sensor.id] = sensor;
    persist();
    return sensor;
  }

  /*
   * Persistence helpers
   */

  @protected
  Future<Map<int, RegisteredSensor>> cacheSensors() async {
    final result = prefs.getStringList(SENSORS_KEY) ?? [];
    return deserialize(result);
  }

  @protected
  Future<void> persist() async {
    final serialized = await serialize(sensors.values);
    await prefs.setStringList(SENSORS_KEY, serialized);
    Log.debug('Persisted $serialized');
  }

  @protected
  Future<Map<int, RegisteredSensor>> deserialize(List<String> result) async {
    final transformed = result.map((str) {
      return RegisteredSensor.fromJson(jsonDecode(str));
    });

    // fill map
    final map = new HashMap<int, RegisteredSensor>();
    for (final entry in transformed) {
      map[entry.id] = entry;
    }
    return map;
  }

  @protected
  Future<List<String>> serialize(Iterable<RegisteredSensor> values) async {
    return values.map((s) => jsonEncode(s.toJson())).toList(growable: false);
  }
}
