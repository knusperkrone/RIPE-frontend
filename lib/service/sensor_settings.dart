import 'dart:collection';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as image;
import 'package:optional/optional.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisteredSensor {
  final int id;
  final String key;
  final String name;
  final String imagePath;

  RegisteredSensor(this.id, this.key, this.name, this.imagePath)
      : assert(id != null &&
            key != null &&
            name != null &&
            name.trim().isNotEmpty &&
            imagePath != null);
}

class SensorSettingService {
  /*
   * Singleton logic
   */

  static SensorSettingService _instance;

  factory SensorSettingService() => _instance ??= SensorSettingService._();

  SensorSettingService._();

  /*
   * fields
   */

  static const _SENSORS_KEY = 'SENSORS_KEY_V1';
  static const _DELIMITER = '\n\r';
  static const _PLACEHOLDER_NAME = '__DEFAULT_PLACEHOLDER.png';

  SharedPreferences _prefs;
  Directory _applicationDir;

  Map<int, RegisteredSensor> _registered;

  /*
   * Constructor
   */

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _applicationDir = await getApplicationDocumentsDirectory();
    _registered = await _fetch();
    _initPlaceHolderImage();
  }

  /*
   * Business methods
   */

  Optional<RegisteredSensor> addSensor(
      int id, String key, String name, String imagePath) {
    if (_registered.containsKey(id)) {
      return const Optional.empty();
    }

    if (imagePath == null) {
      imagePath = placeholder;
    } else {
      // Generate thumbnail and set it as image
      final thumbnailPath = _getThumbnailPath('0_thumbnail_$id.png');
      _resizeImage(imagePath, thumbnailPath);
      imagePath = thumbnailPath;
    }

    final registered = new RegisteredSensor(id, key, name, imagePath);
    _registered[id] = registered;
    _persist();

    print('[INFO] Added new sensor: [$id] $name');
    return Optional.of(registered);
  }

  void removeSensor(int id) {
    _registered.remove(id);
    _persist();
  }

  Optional<List<RegisteredSensor>> getSensors() {
    if (_registered.isEmpty) {
      return const Optional.empty();
    }
    return Optional.of(List.of(_registered.values)); // clone list
  }

  String changeImage(int id, String imagePath) {
    final sensor = _registered[id];
    assert(sensor != null);

    // Workaround for image file caching - always get a new filename
    final oldPath = sensor.imagePath;
    final oldName = path.basename(oldPath);
    final oldIndex = oldName.substring(0, oldName.indexOf('_'));
    final newIndex = (int.tryParse(oldIndex) ?? 1) + 1;

    // Resize image
    final thumbnailPath = _getThumbnailPath('${newIndex}_thumbnail_$id.png');
    _resizeImage(imagePath, thumbnailPath);
    if (!oldPath.endsWith(_PLACEHOLDER_NAME)) {
      File(oldPath).delete();
    }

    // Update state and persist
    _registered[id] =
        RegisteredSensor(id, sensor.key, sensor.name, thumbnailPath);
    _persist();
    return thumbnailPath;
  }

  String changeName(int id, String name) {
    final sensor = _registered[id];
    assert(sensor != null);
    // Update state and persist
    _registered[id] = RegisteredSensor(id, sensor.key, name, sensor.imagePath);
    _persist();
    return name;
  }

  String get placeholder => _getThumbnailPath(_PLACEHOLDER_NAME);

  /*
   * Helpers
   */

  Future<Map<int, RegisteredSensor>> _fetch() async {
    final result = _prefs.getStringList(_SENSORS_KEY);
    if (result?.isEmpty ?? true) {
      return {};
    }

    final transformed = result.map((str) {
      final splits = str.split(_DELIMITER);
      assert(splits.length == 4);
      final id = int.parse(splits[0]);
      final key = splits[1];
      final name = splits[2];
      final imagePath = splits[3];
      return RegisteredSensor(id, key, name, imagePath);
    });
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
      final imagePath = s.imagePath;
      return '$id$_DELIMITER$key$_DELIMITER$name$_DELIMITER$imagePath';
    }).toList(growable: false);

    await _prefs.setStringList(_SENSORS_KEY, persisted);
  }

  void _resizeImage(String imagePath, String thumbPath) {
    final imageFile = new File(imagePath);
    final thumbFile = new File(thumbPath);
    assert(imageFile.existsSync());

    final img = image.decodeImage(imageFile.readAsBytesSync());
    final thumbnailBytes = image.encodePng(image.copyResize(img, width: 120));
    thumbFile.writeAsBytesSync(thumbnailBytes);

    print('[INFO] Generated thumbnail: $thumbPath');
  }

  Future<void> _initPlaceHolderImage() async {
    final placeholderFile = new File(placeholder);
    if (!placeholderFile.existsSync() || placeholderFile.lengthSync() == 0) {
      final imgBytes = await rootBundle.load('assets/icon.png');
      final img = image.decodePng(imgBytes.buffer.asUint8List().toList());
      final thumbnailBytes = image.encodePng(image.copyResize(img, width: 120));
      placeholderFile.createSync(recursive: true);
      placeholderFile.writeAsBytesSync(thumbnailBytes);
      print('[INFO] Generating default thumbnail');
    }
  }

  String _getThumbnailPath(String filename) {
    assert(filename.endsWith('.png'));
    return path.join(_applicationDir.path, 'tmb', filename);
  }
}
