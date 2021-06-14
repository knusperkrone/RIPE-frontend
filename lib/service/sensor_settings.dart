import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as image;
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:ripe/service/base_pref_service.dart';
import 'package:ripe/util/log.dart';

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

class SensorSettingService extends BasePrefService {
  /*
   * Singleton logic
   */

  static final SensorSettingService _instance = SensorSettingService._();

  factory SensorSettingService() => _instance;

  SensorSettingService._();

  /*
   * fields
   */

  static const _SENSORS_KEY = 'SENSORS_KEY_V2';
  static const _DELIMITER = '\n\r';

  late Directory _applicationDir;

  late Map<int, RegisteredSensor> _registered;

  /*
   * Constructor
   */

  @override
  Future<void> init() async {
    super.init();
    _applicationDir = await getApplicationDocumentsDirectory();
    _registered = await _fetch();
    _initPlaceHolderImage();
  }

  /*
   * Business methods
   */

  Future<RegisteredSensor?> addSensor(
      int id, String key, String name, String? imagePath) async {
    if (_registered.containsKey(id)) {
      return null;
    }
    imagePath ??= placeholderPath;

    // copy to app directory folder
    // generate thumbnail
    final appThumbPath = _getThumbnailPath(id);
    _resizeToThumbnail(imagePath, appThumbPath);

    final color = await _generateImageColor(appThumbPath);
    _registered[id] = new RegisteredSensor(
      id,
      key,
      name,
      //appImagePath,
      appThumbPath,
      color,
    );
    _persist();

    Log.info('Added new sensor $id, $name');
    return _registered[id]!;
  }

  void removeSensor(int id) {
    final sensor = _registered[id]!;
    File(sensor.thumbPath).deleteSync();

    _registered.remove(id);
    _persist();
    Log.info('Removed sensor $id, ${sensor.name}');
  }

  List<RegisteredSensor>? getSensors() {
    if (_registered.isEmpty) {
      return null;
    }
    Log.debug('Loaded ${_registered.length} sensors');
    return List.of(_registered.values); // clone list
  }

  Future<RegisteredSensor> changeImage(int id, String imagePath) async {
    final sensor = _registered[id]!;
    final appThumbnailPath = _getThumbnailPath(id);
    _resizeToThumbnail(imagePath, appThumbnailPath);

    // Update state and persist
    final color = await _generateImageColor(appThumbnailPath);
    _registered[id] = RegisteredSensor(
      id,
      sensor.key,
      sensor.name,
      appThumbnailPath,
      color,
    );
    _persist();

    return _registered[id]!;
  }

  RegisteredSensor changeName(int id, String name) {
    final sensor = _registered[id]!;
    // Update state and persist
    final thumbPath = _getThumbnailPath(id);
    _registered[id] = RegisteredSensor(
      id,
      sensor.key,
      name,
      // imagePath,
      thumbPath,
      sensor.imageColor,
    );
    _persist();

    return _registered[id]!;
  }

  String get placeholderPath => _getThumbnailPath(-1);

  Color get placeholderThumbnailColor => const Color(0x00000000);

  /*
   * Helpers
   */

  Future<Map<int, RegisteredSensor>> _fetch() async {
    final result = prefs.getStringList(_SENSORS_KEY);
    if (result == null || result.isEmpty) {
      return {};
    }

    final transformed = result.map((str) {
      final splits = str.split(_DELIMITER);
      final id = int.parse(splits[0]);
      final key = splits[1];
      final name = splits[2];
      final color = (splits.length >= 4)
          ? Color(int.parse(splits[3]))
          : const Color(0xff000000);

      //final imagePath = _getImagePath(id);
      final thumbPath = _getThumbnailPath(id);
      return RegisteredSensor(id, key, name, thumbPath, color);
    });

    // fill map
    final map = new HashMap<int, RegisteredSensor>();
    for (final entry in transformed) {
      map[entry.id] = entry;
    }
    return map;
  }

  Future<void> _persist() async {
    final persisted = _registered.values.map((s) {
      final id = s.id;
      final key = s.key;
      final name = s.name;
      final imageColor = s.imageColor.value;
      return '$id$_DELIMITER$key$_DELIMITER$name$_DELIMITER$imageColor';
    }).toList(growable: false);

    await prefs.setStringList(_SENSORS_KEY, persisted);
  }

  File _resizeToThumbnail(String imagePath, String thumbPath) {
    final imageFile = new File(imagePath);
    final thumbFile = new File(thumbPath);
    assert(imageFile.existsSync());

    final img = image.decodeImage(imageFile.readAsBytesSync())!;
    final thumbnailBytes = image.encodePng(image.copyResize(img, width: 240));
    thumbFile.writeAsBytesSync(thumbnailBytes);

    Log.info('Generated thumbnail for $imagePath at $thumbPath');
    return thumbFile;
  }

  Future<Color> _generateImageColor(String path) async {
    final imageProvider = new FileImage(new File(path));
    final palette = await PaletteGenerator.fromImageProvider(imageProvider);
    return (palette.lightVibrantColor ??
            palette.vibrantColor ??
            palette.dominantColor)!
        .color;
  }

  Future<void> _initPlaceHolderImage() async {
    final placeholderFile = new File(placeholderPath);
    if (!placeholderFile.existsSync() || placeholderFile.lengthSync() == 0) {
      final imgBytes = await rootBundle.load('assets/icon.png');
      final img = image.decodePng(imgBytes.buffer.asUint8List().toList())!;
      final thumbnailBytes = image.encodePng(image.copyResize(img, width: 120));
      placeholderFile.createSync(recursive: true);
      placeholderFile.writeAsBytesSync(thumbnailBytes);

      Log.info('Generated default thumbnail');
    }
  }

  String _getThumbnailPath(int sensorId) {
    return path.join(_applicationDir.path, 'tmb', 'img_$sensorId.jpg');
  }
}
