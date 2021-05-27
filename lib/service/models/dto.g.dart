// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SensorDataDto _$SensorDataDtoFromJson(Map<String, dynamic> json) {
  return SensorDataDto(
    DateTime.parse(json['timestamp'] as String),
    (json['battery'] as num?)?.toDouble(),
    (json['moisture'] as num?)?.toDouble(),
    (json['temperature'] as num?)?.toDouble(),
    json['carbon'] as int?,
    json['conductivity'] as int?,
    json['light'] as int?,
  );
}

AgentRenderDto _$AgentRenderDtoFromJson(Map<String, dynamic> json) {
  return AgentRenderDto(
    AgentDecoratorDto.fromJson(json['decorator'] as Map<String, dynamic>),
    AgentStateDto.fromJson(json['state']),
    json['rendered'] as String,
  );
}

AgentDto _$AgentDtoFromJson(Map<String, dynamic> json) {
  return AgentDto(
    json['domain'] as String,
    json['agent_name'] as String,
    AgentRenderDto.fromJson(json['ui'] as Map<String, dynamic>),
  );
}

SensorDto _$SensorDtoFromJson(Map<String, dynamic> json) {
  return SensorDto(
    json['name'] as String,
    json['broker'] as String?,
    SensorDataDto.fromJson(json['data'] as Map<String, dynamic>),
    (json['agents'] as List<dynamic>)
        .map((dynamic e) => AgentDto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
