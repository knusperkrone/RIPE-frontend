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

BrokerCredentialsDto _$BrokerCredentialsDtoFromJson(
        Map<String, dynamic> json) =>
    BrokerCredentialsDto(
      json['username'] as String,
      json['password'] as String,
    );

BrokerConnectionDetailsDto _$BrokerConnectionDetailsDtoFromJson(
        Map<String, dynamic> json) =>
    BrokerConnectionDetailsDto(
      json['scheme'] as String,
      json['host'] as String,
      json['port'] as int,
      json['credentials'] == null
          ? null
          : BrokerCredentialsDto.fromJson(
              json['credentials'] as Map<String, dynamic>),
    );

BrokersDto _$BrokersDtoFromJson(Map<String, dynamic> json) => BrokersDto(
      (json['items'] as List<dynamic>)
          .map((e) =>
              BrokerConnectionDetailsDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

SensorDto _$SensorDtoFromJson(Map<String, dynamic> json) => SensorDto(
      BrokersDto.fromJson(json['broker'] as Map<String, dynamic>),
      SensorDataDto.fromJson(json['data'] as Map<String, dynamic>),
      (json['agents'] as List<dynamic>)
          .map((e) => AgentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
