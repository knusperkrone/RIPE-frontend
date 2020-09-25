// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SensorDataDto _$SensorDataDtoFromJson(Map<String, dynamic> json) {
  return SensorDataDto(
    json['timestamp'] == null
        ? null
        : DateTime.parse(json['timestamp'] as String),
    json['battery'] as int,
    json['moisture'] as int,
    (json['temperature'] as num)?.toDouble(),
    json['carbon'] as int,
    json['conductivity'] as int,
    json['light'] as int,
  );
}

AgentRenderDto _$AgentRenderDtoFromJson(Map<String, dynamic> json) {
  return AgentRenderDto(
    json['decorator'] == null
        ? null
        : AgentDecoratorDto.fromJson(json['decorator'] as Map<String, dynamic>),
    json['state'] == null
        ? null
        : AgentStateDto.fromJson(json['state'] as dynamic),
    json['rendered'] as String,
  );
}

AgentDto _$AgentDtoFromJson(Map<String, dynamic> json) {
  return AgentDto(
    json['domain'] as String,
    json['agent_name'] as String,
    json['ui'] == null
        ? null
        : AgentRenderDto.fromJson(json['ui'] as Map<String, dynamic>),
  );
}

SensorDto _$SensorDtoFromJson(Map<String, dynamic> json) {
  return SensorDto(
    json['name'] as String,
    json['data'] == null
        ? null
        : SensorDataDto.fromJson(json['data'] as Map<String, dynamic>),
    (json['agents'] as List)
        ?.map((dynamic e) =>
            e == null ? null : AgentDto.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}
