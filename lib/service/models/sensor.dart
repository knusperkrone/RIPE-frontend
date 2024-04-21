import 'dart:ui';
import 'package:json_annotation/json_annotation.dart';

part 'sensor.g.dart';

class Nullable<T> {
  final T? value;

  Nullable(this.value);

  bool get isNull => value == null;
}

class ColorJsonConverter implements JsonConverter<Color, int> {
  const ColorJsonConverter();

  @override
  Color fromJson(int json) {
    return Color(json);
  }

  @override
  int toJson(Color object) {
    return object.value;
  }
}

@JsonSerializable()
class RangeConfig {
  double min;
  double max;

  RangeConfig(this.min, this.max);

  factory RangeConfig.fromJson(Map<String, dynamic> json) =>
      _$RangeConfigFromJson(json);

  Map<String, dynamic> toJson() => _$RangeConfigToJson(this);
}

@JsonSerializable()
class NotificationConfig {
  final RangeConfig temperature;
  final RangeConfig moisture;
  double battery;

  NotificationConfig({
    required this.temperature,
    required this.moisture,
    required this.battery,
  });

  factory NotificationConfig.fromJson(Map<String, dynamic> json) =>
      _$NotificationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationConfigToJson(this);

}

@JsonSerializable()
class RegisteredSensor {
  final int id;
  final String key;
  final String name;
  final String thumbPath;
  @ColorJsonConverter()
  final Color imageColor;
  final NotificationConfig? notificationConfig;

  RegisteredSensor(
    this.id,
    this.key,
    this.name,
    this.thumbPath,
    this.imageColor,
    this.notificationConfig,
  );

  factory RegisteredSensor.fromJson(Map<String, dynamic> json) =>
      _$RegisteredSensorFromJson(json);

  Map<String, dynamic> toJson() => _$RegisteredSensorToJson(this);

  RegisteredSensor copyWith(
      {String? name,
      String? thumbPath,
      Color? imageColor,
      Nullable<NotificationConfig>? notificationConfig}) {
    return RegisteredSensor(
      id,
      key,
      name ?? this.name,
      thumbPath ?? this.thumbPath,
      imageColor ?? this.imageColor,
      notificationConfig == null ? null : notificationConfig.value,
    );
  }
}
