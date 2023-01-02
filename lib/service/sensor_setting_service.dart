import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ripe/service/base_pref_service.dart';

import '../util/log.dart';
import 'sensor_settings_native.dart';
import 'sensor_settings_web.dart';

class RegisteredSensor {
  final int id;
  final String key;
  final String name;
  final String thumbPath;
  final Color imageColor;

  RegisteredSensor(
    this.id,
    this.key,
    this.name,
    this.thumbPath,
    this.imageColor,
  );
}

abstract class SensorSettingService extends BasePrefService {
  static const _DELIMITER = '\n\r';
  static const _SENSORS_KEY = 'SENSORS_KEY_V2';

  @protected
  late Map<int, RegisteredSensor> sensors;

  /*
   * Singleton logic
   */

  @protected
  static final SensorSettingService _instance =
      kIsWeb ? new SensorSettingServiceWeb() : new SensorSettingServiceNative();

  static SensorSettingService getInstance() => _instance;

  /*
   * Contract
   */

  @mustCallSuper
  @override
  Future<void> init() async {
    await super.init();
    sensors = await loadSensors();
  }

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

  RegisteredSensor changeName(int id, String name) {
    final sensor = sensors[id]!;
    // Update state and persist
    sensors[id] = RegisteredSensor(
      sensor.id,
      sensor.key,
      name,
      sensor.thumbPath,
      sensor.imageColor,
    );
    persist();

    return sensors[id]!;
  }

  /*
   * Persistence helpers
   */

  @protected
  Future<Map<int, RegisteredSensor>> loadSensors() async {
    final result = prefs.getStringList(_SENSORS_KEY) ?? [];
    return deserialize(result);
  }

  @protected
  Future<void> persist() async {
    final serialized = await serialize(sensors.values);
    await prefs.setStringList(_SENSORS_KEY, serialized);
  }

  @protected
  Future<Map<int, RegisteredSensor>> deserialize(List<String> result) async {
    final transformed = result.map((str) {
      final splits = str.split(_DELIMITER);
      print(splits);
      final id = int.parse(splits[0]);
      final key = splits[1];
      final name = splits[2];
      final color = (splits.length >= 4)
          ? Color(int.parse(splits[3]))
          : const Color(0x00000000);
      const Color(0xff000000);
      final thumbPath = (splits.length >= 5) ? splits[4] : placeholderPath;

      //final imagePath = _getImagePath(id);
      return RegisteredSensor(id, key, name, thumbPath, color);
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
    return values.map((s) {
      return [s.id, s.key, s.name, s.imageColor.value, s.thumbPath]
          .join(_DELIMITER);
    }).toList(growable: false);
  }
}
