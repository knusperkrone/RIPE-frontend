// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SensorDataDto _$SensorDataDtoFromJson(Map<String, dynamic> json) =>
    SensorDataDto(
      DateTime.parse(json['timestamp'] as String),
      (json['battery'] as num?)?.toDouble(),
      (json['moisture'] as num?)?.toDouble(),
      (json['temperature'] as num?)?.toDouble(),
      json['carbon'] as int?,
      json['conductivity'] as int?,
      json['light'] as int?,
    );

AgentRenderDto _$AgentRenderDtoFromJson(Map<String, dynamic> json) =>
    AgentRenderDto(
      AgentDecoratorDto.fromJson(json['decorator'] as Map<String, dynamic>),
      AgentStateDto.fromJson(json['state']),
      json['rendered'] as String,
    );

AgentDto _$AgentDtoFromJson(Map<String, dynamic> json) => AgentDto(
      json['domain'] as String,
      json['agent_name'] as String,
      AgentRenderDto.fromJson(json['ui'] as Map<String, dynamic>),
    );

BrokerDto _$BrokerDtoFromJson(Map<String, dynamic> json) => BrokerDto(
      tcp: json['tcp'] as String?,
      wss: json['wss'] as String?,
    );

SensorDto _$SensorDtoFromJson(Map<String, dynamic> json) => SensorDto(
      BrokerDto.fromJson(json['broker'] as Map<String, dynamic>),
      SensorDataDto.fromJson(json['data'] as Map<String, dynamic>),
      (json['agents'] as List<dynamic>)
          .map((dynamic e) => AgentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
