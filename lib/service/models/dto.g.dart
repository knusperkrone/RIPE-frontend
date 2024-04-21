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

Map<String, dynamic> _$SensorDataDtoToJson(SensorDataDto instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'battery': instance.battery,
      'moisture': instance.moisture,
      'temperature': instance.temperature,
      'carbon': instance.carbon,
      'conductivity': instance.conductivity,
      'light': instance.light,
    };

Map<String, dynamic> _$AgentDecoratorDtoToJson(AgentDecoratorDto instance) =>
    <String, dynamic>{
      'payload': instance.payload,
      'hashCode': instance.hashCode,
    };

AgentRenderDto _$AgentRenderDtoFromJson(Map<String, dynamic> json) =>
    AgentRenderDto(
      decorator:
          AgentDecoratorDto.fromJson(json['decorator'] as Map<String, dynamic>),
      rendered: json['rendered'] as String,
      state: AgentStateDto.fromJson(json['state']),
    );

Map<String, dynamic> _$AgentRenderDtoToJson(AgentRenderDto instance) =>
    <String, dynamic>{
      'decorator': instance.decorator,
      'state': AgentStateDto.toJson(instance.state),
      'rendered': instance.rendered,
    };

AgentDto _$AgentDtoFromJson(Map<String, dynamic> json) => AgentDto(
      json['domain'] as String,
      json['agent_name'] as String,
      AgentRenderDto.fromJson(json['ui'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AgentDtoToJson(AgentDto instance) => <String, dynamic>{
      'domain': instance.domain,
      'agent_name': instance.agentName,
      'ui': instance.ui,
    };

BrokerCredentialsDto _$BrokerCredentialsDtoFromJson(
        Map<String, dynamic> json) =>
    BrokerCredentialsDto(
      json['username'] as String,
      json['password'] as String,
    );

Map<String, dynamic> _$BrokerCredentialsDtoToJson(
        BrokerCredentialsDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

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

Map<String, dynamic> _$BrokerConnectionDetailsDtoToJson(
        BrokerConnectionDetailsDto instance) =>
    <String, dynamic>{
      'scheme': instance.scheme,
      'host': instance.host,
      'port': instance.port,
      'credentials': instance.credentials,
    };

BrokersDto _$BrokersDtoFromJson(Map<String, dynamic> json) => BrokersDto(
      (json['items'] as List<dynamic>)
          .map((e) =>
              BrokerConnectionDetailsDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BrokersDtoToJson(BrokersDto instance) =>
    <String, dynamic>{
      'items': instance.items,
    };

SensorDto _$SensorDtoFromJson(Map<String, dynamic> json) => SensorDto(
      BrokersDto.fromJson(json['broker'] as Map<String, dynamic>),
      SensorDataDto.fromJson(json['data'] as Map<String, dynamic>),
      (json['agents'] as List<dynamic>)
          .map((e) => AgentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SensorDtoToJson(SensorDto instance) => <String, dynamic>{
      'broker': instance.broker,
      'data': instance.sensorData,
      'agents': instance.agents,
    };
