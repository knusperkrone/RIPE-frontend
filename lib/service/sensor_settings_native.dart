import 'dart:io';

import 'package:flutter/foundation.dart' show protected;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:ripe/service/sensor_setting_service.dart';
import 'package:ripe/util/log.dart';

class SensorSettingServiceNative extends SensorSettingService {
  /*
   * fields
   */

  late Directory _photoDirectory;

  /*
   * Constructor
   */

  @protected
  SensorSettingServiceNative();

  @override
  Future<void> init() async {
    _photoDirectory = await getApplicationDocumentsDirectory();
    _initPlaceHolderImage();
    await super.init();
  }

/*
   * Business methods
   */

  @override
  Future<RegisteredSensor?> addSensor(
      int id, String key, String name, String? imagePath) async {
    if (sensors.containsKey(id)) {
      return null;
    }
    imagePath ??= placeholderPath;

    // copy to app directory folder
    // generate thumbnail
    final appThumbPath = _getThumbnailPath(id);
    _resizeToThumbnail(imagePath, appThumbPath);

    final color = await _generateImageColor(appThumbPath);
    sensors[id] = new RegisteredSensor(
      id,
      key,
      name,
      //appImagePath,
      appThumbPath,
      color,
    );
    persist();

    Log.info('Added new sensor $id, $name');
    return sensors[id]!;
  }

  @override
  void removeSensor(int id) {
    final sensor = sensors[id]!;
    File(_getThumbnailPath(id)).deleteSync();

    sensors.remove(id);
    persist();
    Log.info('Removed sensor $id, ${sensor.name}');
  }

  @override
  Future<RegisteredSensor> changeImage(int id, String imagePath) async {
    final sensor = sensors[id]!;
    final appThumbnailPath = _getThumbnailPath(id);
    _resizeToThumbnail(imagePath, appThumbnailPath);

    // Update state and persist
    final color = await _generateImageColor(appThumbnailPath);
    sensors[id] = RegisteredSensor(
      id,
      sensor.key,
      sensor.name,
      appThumbnailPath,
      color,
    );
    persist();

    return sensors[id]!;
  }

  @override
  String get placeholderPath => _getThumbnailPath(-1);

  @override
  Color get placeholderThumbnailColor => const Color(0x00000000);

  /*
   * Image helpers
   */

  File _resizeToThumbnail(String imagePath, String thumbPath) {
    final imageFile = new File(imagePath);
    final thumbFile = new File(thumbPath);
    assert(imageFile.existsSync());

    final img = image.decodeImage(imageFile.readAsBytesSync())!;
    final thumbnailBytes = image.encodePng(image.copyResize(img, width: 500));
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

  String _getThumbnailPath(int id) {
    return path.join(_photoDirectory.path, 'tmb', 'img_$id.jpg');
  }

  Future<void> _initPlaceHolderImage() async {
    final placeholderFile = new File(placeholderPath);
    if (!placeholderFile.existsSync() || placeholderFile.lengthSync() == 0) {
      final imgBytes = await rootBundle.load('assets/icon.png');
      final img = image.decodePng(imgBytes.buffer.asUint8List())!;
      final thumbnailBytes = image.encodePng(image.copyResize(img, width: 256));
      placeholderFile.createSync(recursive: true);
      placeholderFile.writeAsBytesSync(thumbnailBytes);

      Log.info('Generated default thumbnail');
    }
  }
}
