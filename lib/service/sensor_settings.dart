import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as image;
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:ripe/service/base_pref_service.dart';
import 'package:ripe/util/log.dart';
import 'package:tuple/tuple.dart';

class RegisteredSensor {
  final int id;
  final String key;
  final String name;
  final String imagePath;
  final Color imageColor;

  RegisteredSensor(
      this.id, this.key, this.name, this.imagePath, this.imageColor);
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

  static const _SENSORS_KEY = 'SENSORS_KEY_V1';
  static const _DELIMITER = '\n\r';
  static const _PLACEHOLDER_NAME = '__DEFAULT_PLACEHOLDER.png';

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

    if (imagePath == null) {
      imagePath = placeholder;
    } else {
      // Generate thumbnail and set it as image
      final thumbnailPath = _getThumbnailPath('0_thumbnail_$id.png');
      _resizeImage(imagePath, thumbnailPath);
      imagePath = thumbnailPath;
    }

    final color = await _generateImageColor(imagePath);
    final registered = new RegisteredSensor(id, key, name, imagePath, color);
    _registered[id] = registered;
    _persist();

    Log.info('Added new sensor $id, $name');
    return registered;
  }

  void removeSensor(int id) {
    final sensor = _registered[id]!;
    if (sensor.imagePath != placeholder) {
      new File(sensor.imagePath).deleteSync();
    }
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

  Future<Tuple2<String, Color>> changeImage(int id, String imagePath) async {
    final sensor = _registered[id]!;

    // Workaround for image file caching - always get a new filename
    final oldPath = sensor.imagePath;
    final oldName = path.basename(oldPath);
    final oldIndex = oldName.substring(0, oldName.indexOf('_'));
    final newIndex = (int.tryParse(oldIndex) ?? 1) + 1;
    final newPath = '${newIndex}_thumbnail_$id.png';
    Log.debug('Changing sensor $id image from $oldPath to $newPath');

    // Resize image
    final thumbnailPath = _getThumbnailPath(newPath);
    _resizeImage(imagePath, thumbnailPath);
    if (!oldPath.endsWith(_PLACEHOLDER_NAME)) {
      File(oldPath).delete();
    }

    // Update state and persist
    final color = await _generateImageColor(thumbnailPath);
    _registered[id] =
        RegisteredSensor(id, sensor.key, sensor.name, thumbnailPath, color);
    _persist();
    return new Tuple2(thumbnailPath, color);
  }

  String changeName(int id, String name) {
    final sensor = _registered[id]!;
    // Update state and persist
    _registered[id] = RegisteredSensor(
        id, sensor.key, name, sensor.imagePath, sensor.imageColor);
    _persist();

    return name;
  }

  String get placeholder => _getThumbnailPath(_PLACEHOLDER_NAME);

  Color get placeholderColor => const Color(0x00000000);

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
      final imagePath = splits[3];
      final color = (splits.length >= 5)
          ? Color(int.parse(splits[4]))
          : const Color(0xff000000);
      return RegisteredSensor(id, key, name, imagePath, color);
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
      final imageColor = s.imageColor.value;
      return '$id$_DELIMITER$key$_DELIMITER$name$_DELIMITER$imagePath$_DELIMITER$imageColor';
    }).toList(growable: false);

    await prefs.setStringList(_SENSORS_KEY, persisted);
  }

  void _resizeImage(String imagePath, String thumbPath) {
    final imageFile = new File(imagePath);
    final thumbFile = new File(thumbPath);
    assert(imageFile.existsSync());

    final img = image.decodeImage(imageFile.readAsBytesSync())!;
    final thumbnailBytes = image.encodePng(image.copyResize(img, width: 120));
    thumbFile.writeAsBytesSync(thumbnailBytes);

    Log.info('Generated thumbnail for $imagePath at $thumbPath');
  }

  Future<Color> _generateImageColor(String imagePath) async {
    final imageProvider = new FileImage(new File(imagePath));
    final palette = await PaletteGenerator.fromImageProvider(imageProvider);
    return (palette.lightVibrantColor ??
            palette.vibrantColor ??
            palette.dominantColor)!
        .color;
  }

  Future<void> _initPlaceHolderImage() async {
    final placeholderFile = new File(placeholder);
    if (!placeholderFile.existsSync() || placeholderFile.lengthSync() == 0) {
      final imgBytes = await rootBundle.load('assets/icon.png');
      final img = image.decodePng(imgBytes.buffer.asUint8List().toList())!;
      final thumbnailBytes = image.encodePng(image.copyResize(img, width: 120));
      placeholderFile.createSync(recursive: true);
      placeholderFile.writeAsBytesSync(thumbnailBytes);

      Log.info('Generated default thumbnail');
    }
  }

  String _getThumbnailPath(String filename) {
    assert(filename.endsWith('.png'));
    return path.join(_applicationDir.path, 'tmb', filename);
  }
}
