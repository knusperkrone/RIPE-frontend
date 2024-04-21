import 'package:flutter/foundation.dart' show protected;
import 'package:flutter/services.dart';
import 'package:ripe/service/models/sensor.dart';
import 'package:ripe/service/sensor_service.dart';
import 'package:ripe/util/log.dart';

class SensorServiceWeb extends SensorService {
  /*
   * Constructor
   */

  @protected
  SensorServiceWeb();

  @override
  Future<void> init() async {
    await super.init();
  }

  @override
  Future<RegisteredSensor?> addSensor(
      int id, String key, String name, String? imagePath) async {
    if (sensors.containsKey(id)) {
      return null;
    }

    // copy to app directory folder
    // generate thumbnail
    const color = Color.fromARGB(0, 0, 0, 0);
    sensors[id] = new RegisteredSensor(
      id,
      key,
      name,
      //appImagePath,
      placeholderPath,
      color,
      null,
    );
    persist();

    Log.info('Added new sensor $id, $name');
    return sensors[id]!;
  }

  @override
  void removeSensor(int id) {
    final sensor = sensors[id]!;

    sensors.remove(id);
    persist();
    Log.info('Removed sensor $id, ${sensor.name}');
  }

  @override
  Future<RegisteredSensor> changeImage(int id, String imagePath) async {
    return sensors[id]!;
  }

  @override
  String get placeholderPath => 'assets/icon.png';

  @override
  Color get placeholderThumbnailColor => const Color(0x00000000);
}
