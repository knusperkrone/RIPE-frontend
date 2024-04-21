// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RangeConfig _$RangeConfigFromJson(Map<String, dynamic> json) => RangeConfig(
      (json['min'] as num).toDouble(),
      (json['max'] as num).toDouble(),
    );

Map<String, dynamic> _$RangeConfigToJson(RangeConfig instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
    };

NotificationConfig _$NotificationConfigFromJson(Map<String, dynamic> json) =>
    NotificationConfig(
      battery: (json['battery'] as num?)?.toDouble() ?? 0,
      temperature:
          RangeConfig.fromJson(json['temperature'] as Map<String, dynamic>),
      moisture: RangeConfig.fromJson(json['moisture'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NotificationConfigToJson(NotificationConfig instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
      'moisture': instance.moisture,
      'battery': instance.battery,
    };

RegisteredSensor _$RegisteredSensorFromJson(Map<String, dynamic> json) =>
    RegisteredSensor(
      json['id'] as int,
      json['key'] as String,
      json['name'] as String,
      json['thumbPath'] as String,
      const ColorJsonConverter().fromJson(json['imageColor'] as int),
      json['notificationConfig'] == null
          ? null
          : NotificationConfig.fromJson(
              json['notificationConfig'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegisteredSensorToJson(RegisteredSensor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'name': instance.name,
      'thumbPath': instance.thumbPath,
      'imageColor': const ColorJsonConverter().toJson(instance.imageColor),
      'notificationConfig': instance.notificationConfig,
    };
